#include <bits/stdc++.h>
#define rep(i, a, b) for (auto i = (a); i < (b); ++i)
#define repc(i, a, b) for (auto i = (a); i <= (b); ++i)
#define repr(i, a, b) for (auto i = (a); i >= (b); --i)
#define LEN(a) int(std::size(a))
#define all(a) std::begin(a), std::end(a)
#define rall(a) std::rbegin(a), std::rend(a)
using ll = long long;
constexpr int INF = 0x3f3f3f3f;
constexpr ll LINF = 0x3f3f3f3f3f3f3f3fLL;

template <class T, class U>
inline bool chmin(T& a, const U& b) {
    return b < a && (a = b, true);
}

template <class T, class U>
inline bool chmax(T& a, const U& b) {
    return b > a && (a = b, true);
}

template <class... Args>
inline void println(Args&&... args) {
    (std::cout << ... << args) << '\n';
}

template <class... Args>
inline void errln(Args&&... args) {
    (std::clog << ... << args) << '\n';
}

template <class Container, class = typename Container::value_type, std::enable_if_t<!std::is_same<Container, std::string>::value, std::nullptr_t> = nullptr>
std::ostream& operator<<(std::ostream& os, const Container& v) {
    for (auto it = std::begin(v); it != std::end(v); ++it) os << &" "[it == std::begin(v)] << *it;
    return os;
}

template <class Container, class = typename Container::value_type, std::enable_if_t<!std::is_same<Container, std::string>::value, std::nullptr_t> = nullptr>
std::istream& operator>>(std::istream& is, Container& v) {
    for (auto&& e : v) is >> e;
    return is;
}

#ifdef LOCAL_DEBUG
#else
#endif

using namespace std;

int main() {
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);

    // Edit here!{{_cursor_}}

    return 0;
}
