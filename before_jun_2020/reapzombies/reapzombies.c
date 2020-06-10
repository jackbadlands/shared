#include <lua.h>
#include <lauxlib.h>
#include <signal.h>
#include <sys/wait.h>
#include <errno.h>

void handle_sigchld(int sig) {
  int saved_errno = errno;
  while (waitpid((pid_t)(-1), 0, WNOHANG) > 0) {}
  errno = saved_errno;
}

static const luaL_reg R[] = {
	{NULL, NULL} /* конец списка экспортируемых функций */
};

/* вызывается при загрузке библиотеку */
LUALIB_API int luaopen_reapzombies(lua_State *L) {
	signal(SIGCHLD, handle_sigchld);
	luaL_register(L, "reapzombies", R);
	return 1; /* завершаемся успешно */
}
