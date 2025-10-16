import { Application } from '@hotwired/stimulus';
import ReactLexicalController from './react_lexical_controller';

const application = Application.start();

// Register controllers
application.register('react-lexical', ReactLexicalController);

export { application };
