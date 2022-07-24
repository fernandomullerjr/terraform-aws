import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Manual da Digital Ocean
        </p>
        <a
          className="App-link"
          href="https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-debian-10"
          target="_blank"
          rel="noopener noreferrer"
        >
          Instalando o nodejs
        </a>
      </header>
    </div>
  );
}

export default App;
