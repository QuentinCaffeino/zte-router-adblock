An attempt to automize blocking ads on my home ZTE router which has ~~failed because it has limited its size of rules to 50~~ semi-succeeded.

This program gets 50 most prevailed rules (domains, and urls from [duckduckgo/tracker-radar](https://github.com/duckduckgo/tracker-radar)) and pushes them to local router.

### Requirements:

curl, sed, python3

### Usage:

```
$ ./run ROUTER_IP SID_COOKIE
```

SID_COOKIE should be replaced with your cookie. To obtain it open your browser, go to yours roter admin page, login, open dev-tools find and copy SID cookie.

Tested on ZTE ZXHN H267A V1.0

---

Special thanks to awesome search engine [DuckDuckGo](duckduckgo.com), you should check them out.

Inspired by [tanrax/maza-ad-blocking](https://github.com/tanrax/maza-ad-blocking)

---

### Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
