import React, { useEffect, useState } from "react";
import "./NavBar.scss";
import { Link } from "react-router-dom";
import schedule from "node-schedule";
function NavBar() {
  const [time, SetTime] = useState(new Date().toLocaleTimeString());
  useEffect(() => {
    const setTime = () => {
      SetTime(new Date().toLocaleTimeString());
    };

    let date = new Date();
    date.setSeconds(date.getSeconds() + 1);
    schedule.scheduleJob(date, () => {
      setTime();
    });
  }, [time]);

  return (
    <div className="NavBar_app">
      <div className="NavBar_title">
        <Link to="/">
          <img src="./img/logo.png" alt="logo" />
        </Link>
        <div className="Navbar_time">{time}</div>
      </div>
      <div>
        <ul className="NavBar_ul">
          <Link to="/MyPage" className="menu-item">
            <li>My Page</li>
          </Link>

          <Link to="/CryptoWorld" className="menu-item">
            <li>Crypto World</li>
          </Link>

          <Link to="/SignIn" className="menu-item">
            <li>SignIn</li>
          </Link>

          <Link to="/LogIn" className="menu-item">
            <li>LogIn</li>
          </Link>
        </ul>
      </div>
    </div>
  );
}

export default NavBar;
