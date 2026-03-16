# FILE_HANDLING

**Status**: Active | Domain: Feature  
**Related Modules**: API_DESIGN, BACKEND_PATTERNS, SECURITY_CHECKLIST, PERFORMANCE_OPTIMIZATION

## Purpose

This module provides comprehensive guidance for implementing file upload, download, streaming, validation, and storage in applications. It covers multipart uploads, resumable transfers, file validation, virus scanning, cloud storage integration, and performance optimization. Use this module to build secure, scalable file handling systems.

## When to Use This Module

Reference this module when:
- Implementing file upload functionality
- Building document management systems
- Creating image or video processing pipelines
- Implementing file download with resumable support
- Integrating with cloud storage (S3, Azure Blob, GCS)
- Adding file validation and security scanning
- Optimizing large file transfers
- Building content delivery systems
- Troubleshooting file handling performance or security issues

## File Upload

### Basic Multipart Upload (Express + Multer)

```typescript
import express from 'express';
import multer from 'multer';
import path from 'path';
import crypto from 'crypto';

const app = express();

// Configure storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    // Generate unique filename
    const uniqueSuffix = `${Date.now()}-${crypto.randomBytes(6).toString('hex')}`;
    cb(null, `${file.fieldname}-${uniqueSuffix}${path.extname(file.originalname)}`);
  }
});

// File filter
const fileFilter = (req: any, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  // Allowed MIME types
  const allowedMimes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];
  
  if (allowedMimes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error(`Invalid file type. Allowed types: ${allowedMimes.join(', ')}`));
  }
};

// Configure multer
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
    files: 5 // Max 5 files per request
  }
});

// Single file upload
app.post('/upload', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  
  res.json({
    message: 'File uploaded successfully',
    file: {
      filename: req.file.filename,
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size,
      path: req.file.path
    }
  });
});

// Multiple files upload
app.post('/upload/multiple', upload.array('files', 5), (req, res) => {
  if (!req.files || req.files.length === 0) {
    return res.status(400).json({ error: 'No files uploaded' });
  }
  
  const files = (req.files as Express.Multer.File[]).map(file => ({
    filename: file.filename,
    originalname: file.originalname,
    mimetype: file.mimetype,
    size: file.size
  }));
  
  res.json({
    message: 'Files uploaded successfully',
    files
  });
});

// Multiple fields
app.post('/upload/fields', upload.fields([
  { name: 'avatar', maxCount: 1 },
  { name: 'documents', maxCount: 5 }
]), (req, res) => {
  const files = req.files as { [fieldname: string]: Express.Multer.File[] };
  
  res.json({
    avatar: files['avatar']?.[0],
    documents: files['documents'] || []
  });
});

// Error handling
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: 'File too large' });
    }
    if (err.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({ error: 'Too many files' });
    }
  }
  
  res.status(400).json({ error: err.message });
});
```

### Chunked Upload (Large Files)

```typescript
import fs from 'fs';
import path from 'path';

// Initialize chunked upload
app.post('/upload/init', async (req, res) => {
  const { filename, filesize, chunkSize = 1024 * 1024 } = req.body;
  
  const uploadId = crypto.randomUUID();
  const uploadDir = path.join('uploads', 'chunks', uploadId);
  
  await fs.promises.mkdir(uploadDir, { recursive: true });
  
  // Store upload metadata
  await db.uploads.create({
    id: uploadId,
    filename,
    filesize,
    chunkSize,
    uploadedChunks: 0,
    totalChunks: Math.ceil(filesize / chunkSize),
    status: 'in_progress'
  });
  
  res.json({ uploadId, chunkSize });
});

// Upload chunk
app.post('/upload/chunk/:uploadId', upload.single('chunk'), async (req, res) => {
  const { uploadId } = req.params;
  const { chunkIndex } = req.body;
  
  if (!req.file) {
    return res.status(400).json({ error: 'No chunk uploaded' });
  }
  
  const uploadRecord = await db.uploads.findById(uploadId);
  
  if (!uploadRecord) {
    return res.status(404).json({ error: 'Upload not found' });
  }
  
  // Save chunk
  const chunkPath = path.join('uploads', 'chunks', uploadId, `chunk-${chunkIndex}`);
  await fs.promises.rename(req.file.path, chunkPath);
  
  // Update upload record
  await db.uploads.update(uploadId, {
    uploadedChunks: uploadRecord.uploadedChunks + 1
  });
  
  res.json({
    message: 'Chunk uploaded',
    uploadedChunks: uploadRecord.uploadedChunks + 1,
    totalChunks: uploadRecord.totalChunks
  });
});

// Complete upload (merge chunks)
app.post('/upload/complete/:uploadId', async (req, res) => {
  const { uploadId } = req.params;
  
  const uploadRecord = await db.uploads.findById(uploadId);
  
  if (!uploadRecord) {
    return res.status(404).json({ error: 'Upload not found' });
  }
  
  if (uploadRecord.uploadedChunks !== uploadRecord.totalChunks) {
    return res.status(400).json({ error: 'Not all chunks uploaded' });
  }
  
  // Merge chunks
  const chunksDir = path.join('uploads', 'chunks', uploadId);
  const outputPath = path.join('uploads', uploadRecord.filename);
  const writeStream = fs.createWriteStream(outputPath);
  
  for (let i = 0; i < uploadRecord.totalChunks; i++) {
    const chunkPath = path.join(chunksDir, `chunk-${i}`);
    const chunkData = await fs.promises.readFile(chunkPath);
    writeStream.write(chunkData);
  }
  
  writeStream.end();
  
  // Cleanup chunks
  await fs.promises.rm(chunksDir, { recursive: true });
  
  await db.uploads.update(uploadId, { status: 'completed' });
  
  res.json({
    message: 'Upload completed',
    filename: uploadRecord.filename,
    path: outputPath
  });
});
```

### Client-Side Chunked Upload

```typescript
class ChunkedUploader {
  private chunkSize = 1024 * 1024; // 1MB chunks
  
  async uploadFile(file: File, onProgress?: (progress: number) => void): Promise<void> {
    // Initialize upload
    const initResponse = await fetch('/upload/init', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        filename: file.name,
        filesize: file.size,
        chunkSize: this.chunkSize
      })
    });
    
    const { uploadId, chunkSize } = await initResponse.json();
    const totalChunks = Math.ceil(file.size / chunkSize);
    
    // Upload chunks
    for (let i = 0; i < totalChunks; i++) {
      const start = i * chunkSize;
      const end = Math.min(start + chunkSize, file.size);
      const chunk = file.slice(start, end);
      
      await this.uploadChunk(uploadId, i, chunk);
      
      // Report progress
      if (onProgress) {
        onProgress((i + 1) / totalChunks * 100);
      }
    }
    
    // Complete upload
    await fetch(`/upload/complete/${uploadId}`, { method: 'POST' });
  }
  
  private async uploadChunk(uploadId: string, chunkIndex: number, chunk: Blob): Promise<void> {
    const formData = new FormData();
    formData.append('chunk', chunk);
    formData.append('chunkIndex', chunkIndex.toString());
    
    const response = await fetch(`/upload/chunk/${uploadId}`, {
      method: 'POST',
      body: formData
    });
    
    if (!response.ok) {
      throw new Error(`Chunk ${chunkIndex} upload failed`);
    }
  }
}

// Usage
const uploader = new ChunkedUploader();

document.getElementById('fileInput')?.addEventListener('change', async (e) => {
  const input = e.target as HTMLInputElement;
  const file = input.files?.[0];
  
  if (file) {
    await uploader.uploadFile(file, (progress) => {
      console.log(`Upload progress: ${progress.toFixed(2)}%`);
    });
  }
});
```

## File Validation

### MIME Type Validation

```typescript
import fileType from 'file-type';

async function validateFileType(filePath: string, allowedTypes: string[]): Promise<boolean> {
  const type = await fileType.fromFile(filePath);
  
  if (!type) {
    return false;
  }
  
  return allowedTypes.includes(type.mime);
}

// Usage
app.post('/upload', upload.single('file'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  
  const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'];
  const isValid = await validateFileType(req.file.path, allowedTypes);
  
  if (!isValid) {
    await fs.promises.unlink(req.file.path);
    return res.status(400).json({ error: 'Invalid file type' });
  }
  
  res.json({ message: 'File uploaded successfully' });
});
```

### Image Validation

```typescript
import sharp from 'sharp';

async function validateImage(filePath: string): Promise<{
  valid: boolean;
  metadata?: sharp.Metadata;
  error?: string;
}> {
  try {
    const metadata = await sharp(filePath).metadata();
    
    // Check dimensions
    if (!metadata.width || !metadata.height) {
      return { valid: false, error: 'Invalid image dimensions' };
    }
    
    // Check max dimensions
    const maxWidth = 5000;
    const maxHeight = 5000;
    
    if (metadata.width > maxWidth || metadata.height > maxHeight) {
      return { valid: false, error: 'Image dimensions too large' };
    }
    
    // Check format
    const allowedFormats = ['jpeg', 'png', 'webp', 'gif'];
    if (!metadata.format || !allowedFormats.includes(metadata.format)) {
      return { valid: false, error: 'Unsupported image format' };
    }
    
    return { valid: true, metadata };
  } catch (error) {
    return { valid: false, error: 'Invalid image file' };
  }
}
```

### Virus Scanning

```typescript
import NodeClam from 'clamscan';

// Initialize ClamAV scanner
const clam = await new NodeClam().init({
  clamdscan: {
    host: 'localhost',
    port: 3310
  }
});

async function scanFile(filePath: string): Promise<{
  isInfected: boolean;
  viruses?: string[];
}> {
  const { isInfected, viruses } = await clam.scanFile(filePath);
  
  return { isInfected, viruses };
}

// Middleware for virus scanning
async function virusScanMiddleware(req: express.Request, res: express.Response, next: express.NextFunction) {
  if (!req.file) {
    return next();
  }
  
  const { isInfected, viruses } = await scanFile(req.file.path);
  
  if (isInfected) {
    // Delete infected file
    await fs.promises.unlink(req.file.path);
    
    return res.status(400).json({
      error: 'File is infected',
      viruses
    });
  }
  
  next();
}

// Usage
app.post('/upload', upload.single('file'), virusScanMiddleware, (req, res) => {
  res.json({ message: 'File uploaded successfully' });
});
```

## File Download

### Basic Download

```typescript
app.get('/download/:filename', async (req, res) => {
  const { filename } = req.params;
  const filePath = path.join('uploads', filename);
  
  // Check file exists
  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ error: 'File not found' });
  }
  
  // Set headers
  res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
  res.setHeader('Content-Type', 'application/octet-stream');
  
  // Stream file
  const fileStream = fs.createReadStream(filePath);
  fileStream.pipe(res);
});
```

### Resumable Download (Range Requests)

```typescript
app.get('/download/resumable/:filename', async (req, res) => {
  const { filename } = req.params;
  const filePath = path.join('uploads', filename);
  
  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ error: 'File not found' });
  }
  
  const stat = await fs.promises.stat(filePath);
  const fileSize = stat.size;
  const range = req.headers.range;
  
  if (range) {
    // Parse range header
    const parts = range.replace(/bytes=/, '').split('-');
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
    const chunkSize = end - start + 1;
    
    // Set partial content headers
    res.status(206);
    res.setHeader('Content-Range', `bytes ${start}-${end}/${fileSize}`);
    res.setHeader('Accept-Ranges', 'bytes');
    res.setHeader('Content-Length', chunkSize);
    res.setHeader('Content-Type', 'application/octet-stream');
    
    // Stream partial content
    const fileStream = fs.createReadStream(filePath, { start, end });
    fileStream.pipe(res);
  } else {
    // No range requested, send full file
    res.setHeader('Content-Length', fileSize);
    res.setHeader('Content-Type', 'application/octet-stream');
    
    const fileStream = fs.createReadStream(filePath);
    fileStream.pipe(res);
  }
});
```

### Signed Download URLs (Expiring Links)

```typescript
import crypto from 'crypto';

function generateSignedUrl(filename: string, expiresIn: number = 3600): string {
  const expires = Date.now() + expiresIn * 1000;
  
  const signature = crypto
    .createHmac('sha256', process.env.SECRET_KEY!)
    .update(`${filename}:${expires}`)
    .digest('hex');
  
  return `/download/signed/${filename}?expires=${expires}&signature=${signature}`;
}

function verifySignature(filename: string, expires: number, signature: string): boolean {
  if (Date.now() > expires) {
    return false;
  }
  
  const expectedSignature = crypto
    .createHmac('sha256', process.env.SECRET_KEY!)
    .update(`${filename}:${expires}`)
    .digest('hex');
  
  return signature === expectedSignature;
}

app.get('/download/signed/:filename', (req, res) => {
  const { filename } = req.params;
  const { expires, signature } = req.query;
  
  if (!verifySignature(filename, parseInt(expires as string), signature as string)) {
    return res.status(403).json({ error: 'Invalid or expired signature' });
  }
  
  const filePath = path.join('uploads', filename);
  res.download(filePath);
});
```

## Cloud Storage Integration

### AWS S3

```typescript
import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const s3Client = new S3Client({
  region: process.env.AWS_REGION!,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!
  }
});

// Upload to S3
async function uploadToS3(file: Express.Multer.File, key: string): Promise<string> {
  const command = new PutObjectCommand({
    Bucket: process.env.S3_BUCKET!,
    Key: key,
    Body: fs.createReadStream(file.path),
    ContentType: file.mimetype
  });
  
  await s3Client.send(command);
  
  return `https://${process.env.S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
}

// Generate presigned URL for upload
async function generatePresignedUploadUrl(key: string, expiresIn: number = 3600): Promise<string> {
  const command = new PutObjectCommand({
    Bucket: process.env.S3_BUCKET!,
    Key: key
  });
  
  return await getSignedUrl(s3Client, command, { expiresIn });
}

// Generate presigned URL for download
async function generatePresignedDownloadUrl(key: string, expiresIn: number = 3600): Promise<string> {
  const command = new GetObjectCommand({
    Bucket: process.env.S3_BUCKET!,
    Key: key
  });
  
  return await getSignedUrl(s3Client, command, { expiresIn });
}

// Delete from S3
async function deleteFromS3(key: string): Promise<void> {
  const command = new DeleteObjectCommand({
    Bucket: process.env.S3_BUCKET!,
    Key: key
  });
  
  await s3Client.send(command);
}

// Usage
app.post('/upload/s3', upload.single('file'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  
  const key = `uploads/${Date.now()}-${req.file.originalname}`;
  const url = await uploadToS3(req.file, key);
  
  // Delete local file
  await fs.promises.unlink(req.file.path);
  
  res.json({ url, key });
});
```

## Image Processing

### Resize and Optimize

```typescript
import sharp from 'sharp';

async function processImage(inputPath: string, outputPath: string, options: {
  width?: number;
  height?: number;
  quality?: number;
  format?: 'jpeg' | 'png' | 'webp';
}): Promise<void> {
  const { width, height, quality = 80, format = 'jpeg' } = options;
  
  let pipeline = sharp(inputPath);
  
  if (width || height) {
    pipeline = pipeline.resize(width, height, {
      fit: 'inside',
      withoutEnlargement: true
    });
  }
  
  switch (format) {
    case 'jpeg':
      pipeline = pipeline.jpeg({ quality });
      break;
    case 'png':
      pipeline = pipeline.png({ quality });
      break;
    case 'webp':
      pipeline = pipeline.webp({ quality });
      break;
  }
  
  await pipeline.toFile(outputPath);
}

// Generate multiple sizes
async function generateThumbnails(inputPath: string, outputDir: string): Promise<{
  thumbnail: string;
  small: string;
  medium: string;
  large: string;
}> {
  const basename = path.basename(inputPath, path.extname(inputPath));
  
  const sizes = {
    thumbnail: { width: 150, height: 150 },
    small: { width: 320, height: 320 },
    medium: { width: 640, height: 640 },
    large: { width: 1280, height: 1280 }
  };
  
  const results: any = {};
  
  for (const [name, size] of Object.entries(sizes)) {
    const outputPath = path.join(outputDir, `${basename}-${name}.jpg`);
    await processImage(inputPath, outputPath, size);
    results[name] = outputPath;
  }
  
  return results;
}
```

## Performance Optimization

### Streaming Large Files

```typescript
import { pipeline } from 'stream/promises';

app.post('/upload/stream', async (req, res) => {
  const filename = `${Date.now()}-upload.bin`;
  const outputPath = path.join('uploads', filename);
  const writeStream = fs.createWriteStream(outputPath);
  
  try {
    await pipeline(req, writeStream);
    res.json({ message: 'File uploaded', filename });
  } catch (error) {
    await fs.promises.unlink(outputPath).catch(() => {});
    res.status(500).json({ error: 'Upload failed' });
  }
});
```

### Memory-Efficient Processing

```typescript
async function processLargeFile(inputPath: string, outputPath: string): Promise<void> {
  const readStream = fs.createReadStream(inputPath, { highWaterMark: 64 * 1024 });
  const writeStream = fs.createWriteStream(outputPath);
  
  // Process in chunks
  for await (const chunk of readStream) {
    const processed = processChunk(chunk);
    writeStream.write(processed);
  }
  
  writeStream.end();
}

function processChunk(chunk: Buffer): Buffer {
  // Transform chunk (e.g., encryption, compression)
  return chunk;
}
```

## Anti-Patterns

### ❌ Loading Entire File into Memory

```typescript
// NEVER DO THIS for large files
const fileContent = await fs.promises.readFile(filePath);
```

**Why it's wrong**: Causes memory exhaustion for large files.

**Do this instead**: Use streams.

### ❌ Trusting Client-Provided MIME Types

```typescript
// NEVER DO THIS
if (req.file.mimetype === 'image/jpeg') {
  // Trust client's MIME type
}
```

**Why it's wrong**: Clients can lie about MIME types.

**Do this instead**: Validate file content with `file-type` library.

### ❌ No File Size Limits

```typescript
// NEVER DO THIS
app.post('/upload', upload.single('file'), (req, res) => {
  // No size limit
});
```

**Why it's wrong**: Vulnerable to DoS via large uploads.

**Do this instead**: Set explicit `limits` in multer config.

### ❌ Storing Uploaded Files in /tmp

```typescript
// NEVER DO THIS
const storage = multer.diskStorage({
  destination: '/tmp'
});
```

**Why it's wrong**: /tmp is often cleared on reboot.

**Do this instead**: Use dedicated upload directory with backups.

## Related Modules

- **API_DESIGN** - File upload/download API design
- **SECURITY_CHECKLIST** - File upload security
- **PERFORMANCE_OPTIMIZATION** - Streaming and caching
- **BACKEND_PATTERNS** - Error handling and middleware
- **AUTH_IMPLEMENTATION** - Securing file access
