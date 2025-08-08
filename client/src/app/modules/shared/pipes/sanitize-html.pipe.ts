import { Pipe, PipeTransform } from '@angular/core';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { GeoLinkService } from '../../../services/core/geolink.service';

/**
 * Sanitizes HTML for use in innerHTML attributes and processes geo: links.
 */
@Pipe({
  name: 'sanitizeHtml',
})
export class SanitizeHtmlPipe implements PipeTransform {
  constructor(
    private _sanitizer: DomSanitizer,
    private geoLinkService: GeoLinkService
  ) {}

  transform(value: string): SafeHtml {
    if (!value) return this._sanitizer.bypassSecurityTrustHtml('');

    // First process geo links based on device type
    const processedContent = this.geoLinkService.processGeoLinks(value);

    // Then sanitize the processed content
    return this._sanitizer.bypassSecurityTrustHtml(processedContent);
  }
}
