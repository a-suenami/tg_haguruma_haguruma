import { Application } from '@hotwired/stimulus';
import ReactLexicalController from './react_lexical_controller';
import AutosaveFormController from './autosave_form_controller';
import AutosaveFieldController from './autosave_field_controller';

const application = Application.start();

// Register controllers
application.register('react-lexical', ReactLexicalController);
application.register('autosave-form', AutosaveFormController);
application.register('autosave-field', AutosaveFieldController);

export { application };
