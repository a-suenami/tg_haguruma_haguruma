import { Application } from '@hotwired/stimulus';
import AccordionController from './accordion_controller';
import ReactLexicalController from './react_lexical_controller';
import AutosaveFormController from './autosave_form_controller';
import AutosaveFieldController from './autosave_field_controller';
import MediaAssetFieldController from './media_asset_field_controller';
import AuthorizationTagsController from './authorization_tags_controller';
import ColorPickerController from './color_picker_controller';
import ContentTypeFieldController from './content_type_field_controller';
import SwiperController from './swiper_controller';
import MobileMenuController from './mobile_menu_controller';
import MenuSettingsController from './menu_settings_controller';

const application = Application.start();

// Register controllers
application.register('accordion', AccordionController);
application.register('react-lexical', ReactLexicalController);
application.register('autosave-form', AutosaveFormController);
application.register('autosave-field', AutosaveFieldController);
application.register('media-asset-field', MediaAssetFieldController);
application.register('authorization-tags', AuthorizationTagsController);
application.register('color-picker', ColorPickerController);
application.register('content-type-field', ContentTypeFieldController);
application.register('mobile-menu', MobileMenuController);
application.register('swiper', SwiperController);
application.register('menu-settings', MenuSettingsController);

export { application };
