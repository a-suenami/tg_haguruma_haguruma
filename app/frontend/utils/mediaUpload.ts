export interface MediaUploadResponse {
  id: string;
  url: string;
  s3_object_path: string;
  filename: string;
  media_type: 'image' | 'video' | 'audio' | 'document';
}

export interface MediaUploadError {
  error: string;
}

/**
 * Allowed MIME types for media upload
 * Must be kept in sync with MimeTypeValidator on the backend
 */
export const ALLOWED_MIME_TYPES = {
  image: ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml'],
  video: ['video/mp4', 'video/webm', 'video/quicktime'],
  audio: ['audio/mpeg', 'audio/wav', 'audio/ogg', 'audio/webm'],
  document: ['application/pdf'],
} as const;

export const ALL_ALLOWED_MIME_TYPES = [
  ...ALLOWED_MIME_TYPES.image,
  ...ALLOWED_MIME_TYPES.video,
  ...ALLOWED_MIME_TYPES.audio,
  ...ALLOWED_MIME_TYPES.document,
];

export const ALLOWED_EXTENSIONS = [
  'JPEG', 'PNG', 'GIF', 'WebP', 'SVG',
  'MP4', 'WebM', 'MOV',
  'MP3', 'WAV', 'OGG',
  'PDF',
];

/**
 * Accept string for file input elements
 */
export const ACCEPT_ATTRIBUTE = ALL_ALLOWED_MIME_TYPES.join(',');

/**
 * Uploads a file to S3 via the admin media upload API
 * Returns a CloudFront URL for the uploaded file
 */
export async function uploadMedia(file: File): Promise<MediaUploadResponse> {
  // クライアントサイドでの事前検証
  validateMimeType(file);

  const formData = new FormData();
  formData.append('file', file);

  // Get CSRF token from meta tag
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

  const response = await fetch('/admin/media/upload', {
    method: 'POST',
    headers: {
      'X-CSRF-Token': csrfToken || '',
    },
    body: formData,
  });

  if (!response.ok) {
    const errorData: MediaUploadError = await response.json();
    throw new Error(errorData.error || 'Upload failed');
  }

  return response.json();
}

/**
 * Checks if a file is an image
 */
export function isImageFile(file: File): boolean {
  return ALLOWED_MIME_TYPES.image.includes(file.type as typeof ALLOWED_MIME_TYPES.image[number]);
}

/**
 * Checks if a file is a video
 */
export function isVideoFile(file: File): boolean {
  return ALLOWED_MIME_TYPES.video.includes(file.type as typeof ALLOWED_MIME_TYPES.video[number]);
}

/**
 * Checks if a file is an audio
 */
export function isAudioFile(file: File): boolean {
  return ALLOWED_MIME_TYPES.audio.includes(file.type as typeof ALLOWED_MIME_TYPES.audio[number]);
}

/**
 * Checks if a file is a document
 */
export function isDocumentFile(file: File): boolean {
  return ALLOWED_MIME_TYPES.document.includes(file.type as typeof ALLOWED_MIME_TYPES.document[number]);
}

/**
 * Checks if a file has an allowed MIME type
 */
export function isAllowedMimeType(file: File): boolean {
  return ALL_ALLOWED_MIME_TYPES.includes(file.type);
}

/**
 * Checks if a file is a supported media type (image or video)
 */
export function isSupportedMediaFile(file: File): boolean {
  return isImageFile(file) || isVideoFile(file);
}

/**
 * Validates a file and throws an error if MIME type is not allowed
 */
export function validateMimeType(file: File): void {
  if (!isAllowedMimeType(file)) {
    throw new Error(`${ALLOWED_EXTENSIONS.join(', ')}のみアップロードできます`);
  }
}
