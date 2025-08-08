import { Directive, ElementRef, Input, OnChanges, SimpleChanges } from '@angular/core';
import { SafeHtml } from '@angular/platform-browser';
import { GeoLinkService } from '../../../services/core/geolink.service';

@Directive({
  selector: '[lcProcessGeoLinks]',
  standalone: true
})
export class GeoLinkDirective implements OnChanges {
  @Input('lcProcessGeoLinks') content: string | SafeHtml = '';

  constructor(
    private elementRef: ElementRef<HTMLElement>,
    private geoLinkService: GeoLinkService
  ) {}

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['content'] && this.content) {
      this.processContent();
    }
  }

  private processContent(): void {
    // Handle both string and SafeHtml content
    const htmlContent = typeof this.content === 'string'
      ? this.content
      : this.content.toString();

    // Set the innerHTML first
    this.elementRef.nativeElement.innerHTML = htmlContent;

    // Then process geo links in the DOM element directly
    this.geoLinkService.processGeoLinksInElement(this.elementRef.nativeElement);
  }
}
