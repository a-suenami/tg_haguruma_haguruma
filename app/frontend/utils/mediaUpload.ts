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
 * Uploads a file to S3 via the admin media upload API
 * Returns a CloudFront URL for the uploaded file
 */
export async function uploadMedia(file: File): Promise<MediaUploadResponse> {
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
  return file.type.startsWith('image/');
}

/**
 * Checks if a file is a video
 */
export function isVideoFile(file: File): boolean {
  return file.type.startsWith('video/');
}

/**
 * Checks if a file is a supported media type (image or video)
 */
export function isSupportedMediaFile(file: File): boolean {
  return isImageFile(file) || isVideoFile(file);
}
