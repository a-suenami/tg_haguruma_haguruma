import { CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';
import { register } from 'swiper/element/bundle';

import { SwiperSlide } from '../swiper-slide/swiper-slide.component';
import { SwiperContainer } from './swiper-container.component';

// Register Swiper custom elements
register();

const meta: Meta<SwiperContainer> = {
  component: SwiperContainer,
  title: 'Core/Components/Swiper/SwiperContainer',
  decorators: [
    moduleMetadata({
      imports: [SwiperContainer, SwiperSlide],
      schemas: [CUSTOM_ELEMENTS_SCHEMA],
    }),
  ],
  parameters: {
    layout: 'centered',
  },
};
export default meta;

type Story = StoryObj<SwiperContainer>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="width: 600px; height: 400px;">
        <swiper-container [options]="{
          slidesPerView: 1,
          spaceBetween: 30,
          navigation: true,
          pagination: { clickable: true }
        }">
          <swiper-slide>
            <div style="display: flex; align-items: center; justify-content: center; height: 400px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; font-size: 2rem;">
              Slide 1
            </div>
          </swiper-slide>
          <swiper-slide>
            <div style="display: flex; align-items: center; justify-content: center; height: 400px; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; font-size: 2rem;">
              Slide 2
            </div>
          </swiper-slide>
          <swiper-slide>
            <div style="display: flex; align-items: center; justify-content: center; height: 400px; background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; font-size: 2rem;">
              Slide 3
            </div>
          </swiper-slide>
        </swiper-container>
      </div>
    `,
  }),
};

export const CenteredSlides: Story = {
  render: () => ({
    template: `
      <div style="width: 800px; height: 300px;">
        <swiper-container [options]="{
          slidesPerView: 'auto',
          centeredSlides: true,
          spaceBetween: 30,
          pagination: { clickable: true },
          navigation: true
        }">
          <swiper-slide style="width: 300px;">
            <div style="display: flex; align-items: center; justify-content: center; height: 300px; background: #f0f0f0; border-radius: 12px;">
              Centered 1
            </div>
          </swiper-slide>
          <swiper-slide style="width: 300px;">
            <div style="display: flex; align-items: center; justify-content: center; height: 300px; background: #f0f0f0; border-radius: 12px;">
              Centered 2
            </div>
          </swiper-slide>
          <swiper-slide style="width: 300px;">
            <div style="display: flex; align-items: center; justify-content: center; height: 300px; background: #f0f0f0; border-radius: 12px;">
              Centered 3
            </div>
          </swiper-slide>
          <swiper-slide style="width: 300px;">
            <div style="display: flex; align-items: center; justify-content: center; height: 300px; background: #f0f0f0; border-radius: 12px;">
              Centered 4
            </div>
          </swiper-slide>
        </swiper-container>
      </div>
    `,
  }),
};
