import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class GeoLinkService {

  /**
   * Processes HTML content to dynamically handle geo: links based on visitor's device
   * @param htmlContent - The HTML content containing potential geo: links
   * @returns Processed HTML with geo: links converted appropriately
   */
  processGeoLinks(htmlContent: string): string {
    if (!htmlContent) return htmlContent;

    // Create a temporary DOM element to safely parse and modify HTML
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = htmlContent;

    // Find all links with geo: href
    const geoLinks = tempDiv.querySelectorAll('a[href^="geo:"]');

    geoLinks.forEach((element) => {
      const link = element as HTMLAnchorElement;
      const geoUrl = link.href;

      if (this.isMobileDevice()) {
        // Mobile: Keep geo: link as-is for native app handling
        link.href = geoUrl;
      } else {
        // Desktop: Convert to OpenStreetMap URL
        const mapUrl = this.convertGeoToMapUrl(geoUrl);
        link.href = mapUrl;
        link.target = '_blank';
        link.rel = 'noopener noreferrer';

        // Add visual indicator that this opens a map
        if (!link.textContent?.includes('🗺️')) {
          link.innerHTML = `🗺️ ${link.innerHTML}`;
        }
      }
    });

    return tempDiv.innerHTML;
  }

  /**
   * Detects if the current visitor is on a mobile device
   */
  private isMobileDevice(): boolean {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  }

  /**
   * Converts geo: URL to OpenStreetMap URL for desktop browsers
   */
  private convertGeoToMapUrl(geoUrl: string): string {
    try {
      // Parse geo: URL format: geo:lat,lon or geo:lat,lon?q=label
      const geoPattern = /^geo:(-?\d+\.?\d*),(-?\d+\.?\d*)(\?.*)?$/;
      const match = geoUrl.match(geoPattern);

      if (match) {
        const lat = match[1];
        const lon = match[2];
        const queryParams = match[3] || '';

        // Extract label if present (q parameter)
        let label = '';
        if (queryParams) {
          const qMatch = queryParams.match(/[?&]q=([^&]*)/);
          if (qMatch) {
            label = decodeURIComponent(qMatch[1]);
          }
        }

        // Create OpenStreetMap URL with marker and appropriate zoom
        return `https://www.openstreetmap.org/?mlat=${lat}&mlon=${lon}&zoom=12&layers=M`;
      }

      // If parsing fails, try Google Maps as fallback
      const coordinates = geoUrl.replace('geo:', '').split('?')[0];
      return `https://maps.google.com/maps?q=${coordinates}`;

    } catch (error) {
      console.warn('Could not parse geo: URL, using Google Maps fallback:', error);
      const coordinates = geoUrl.replace('geo:', '').split('?')[0];
      return `https://maps.google.com/maps?q=${coordinates}`;
    }
  }

  /**
   * Alternative method: Process geo: links in-place within a DOM element
   * Useful for processing content that's already in the DOM
   */
  processGeoLinksInElement(element: HTMLElement): void {
    const geoLinks = element.querySelectorAll('a[href^="geo:"]');

    geoLinks.forEach((element) => {
      const link = element as HTMLAnchorElement;
      const geoUrl = link.href;

      if (this.isMobileDevice()) {
        // Mobile: Keep geo: link as-is
        link.href = geoUrl;
      } else {
        // Desktop: Convert to map URL
        const mapUrl = this.convertGeoToMapUrl(geoUrl);
        link.href = mapUrl;
        link.target = '_blank';
        link.rel = 'noopener noreferrer';

        // Add visual indicator
        if (!link.textContent?.includes('🗺️')) {
          link.innerHTML = `🗺️ ${link.innerHTML}`;
        }
      }
    });
  }
}
