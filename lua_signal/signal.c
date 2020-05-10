#include <signal.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>

// DEBUG SWITCH //////////////////////////////
#define DEBUG 1

#ifdef DEBUG
#include <stdio.h>
#endif

static unsigned long int sigabrt_c = 0;
static unsigned long int sigfpe_c = 0;
static unsigned long int sigill_c = 0;
static unsigned long int sigint_c = 0;
static unsigned long int sigsegv_c = 0;
static unsigned long int sigterm_c = 0;

void sig_handler (int sig) {

#ifdef DEBUG
	printf("lua_signal: signal %d captured\n", sig);
#endif

	switch (sig) {
		case SIGABRT:
			sigabrt_c++;
			break;;
		case SIGFPE:
			sigfpe_c++;
			break;;
		case SIGILL:
			sigill_c++;
			break;;
		case SIGINT:
			sigint_c++;
			break;;
		case SIGSEGV:
			sigsegv_c++;
			break;;
		case SIGTERM:
			sigterm_c++;
			break;;
		default:
			break;;
	}
}

static int luasignal_register(lua_State *L) {

	const char *signame;
	void *prevsigfunc = NULL;

	signame = lua_tostring(L, 1);
	if (signame == NULL) {
		lua_pushnil(L);
		lua_pushstring(L, "signal name (arg. 1) must be a string");
		return 2;
	}

	if (0 == strcmp(signame, "SIGABRT")) {
		prevsigfunc = signal(SIGABRT, sig_handler);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGFPE")) {
		prevsigfunc = signal(SIGFPE, sig_handler);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGILL")) {
		prevsigfunc = signal(SIGILL, sig_handler);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGINT")) {
		prevsigfunc = signal(SIGINT, sig_handler);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGSEGV")) {
		prevsigfunc = signal(SIGSEGV, sig_handler);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGTERM")) {
		prevsigfunc = signal(SIGTERM, sig_handler);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else {
		lua_pushnil(L);
		lua_pushstring(L, "unknown signal name");
		return 2;
	}

	return 1;
}

static int luasignal_unregister(lua_State *L) {

	const char *signame;
	void *prevsigfunc = NULL;

	signame = lua_tostring(L, 1);
	if (signame == NULL) {
		lua_pushnil(L);
		lua_pushstring(L, "signal name (arg. 1) must be a string");
		return 2;
	}

	if (0 == strcmp(signame, "SIGABRT")) {
		prevsigfunc = signal(SIGABRT, SIG_DFL);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGFPE")) {
		prevsigfunc = signal(SIGFPE, SIG_DFL);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGILL")) {
		prevsigfunc = signal(SIGILL, SIG_DFL);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGINT")) {
		prevsigfunc = signal(SIGINT, SIG_DFL);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGSEGV")) {
		prevsigfunc = signal(SIGSEGV, SIG_DFL);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGTERM")) {
		prevsigfunc = signal(SIGTERM, SIG_DFL);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else {
		lua_pushnil(L);
		lua_pushstring(L, "unknown signal name");
		return 2;
	}

	return 1;
}

static int luasignal_ignore(lua_State *L) {

	const char *signame;
	void *prevsigfunc = NULL;

	signame = lua_tostring(L, 1);
	if (signame == NULL) {
		lua_pushnil(L);
		lua_pushstring(L, "signal name (arg. 1) must be a string");
		return 2;
	}

	if (0 == strcmp(signame, "SIGABRT")) {
		prevsigfunc = signal(SIGABRT, SIG_IGN);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGFPE")) {
		prevsigfunc = signal(SIGFPE, SIG_IGN);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGILL")) {
		prevsigfunc = signal(SIGILL, SIG_IGN);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGINT")) {
		prevsigfunc = signal(SIGINT, SIG_IGN);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGSEGV")) {
		prevsigfunc = signal(SIGSEGV, SIG_IGN);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else if (0 == strcmp(signame, "SIGTERM")) {
		prevsigfunc = signal(SIGTERM, SIG_IGN);
		if (prevsigfunc == SIG_ERR) {
			lua_pushboolean(L, 0);
		} else {
			lua_pushboolean(L, 1);
		}
	} else {
		lua_pushnil(L);
		lua_pushstring(L, "unknown signal name");
		return 2;
	}

	return 1;
}

static int luasignal_check(lua_State *L) {

	lua_settop(L, 0);
	lua_newtable(L);

#define RETSIGTOLUA(sigvar, signame) \
	if ((sigvar) > 0) {                \
		lua_pushstring(L, (signame));    \
		lua_pushinteger(L, (sigvar));    \
		lua_settable(L, 1);              \
		(sigvar) = 0;                    \
	}

	RETSIGTOLUA(sigabrt_c, "SIGABRT");
	RETSIGTOLUA(sigfpe_c, "SIGFPE");
	RETSIGTOLUA(sigill_c, "SIGILL");
	RETSIGTOLUA(sigint_c, "SIGINT");
	RETSIGTOLUA(sigsegv_c, "SIGSEGV");
	RETSIGTOLUA(sigterm_c, "SIGTERM");

#undef RETSIGTOLUA

	return 1;
}

static const luaL_reg R[] = {

	{"register",   luasignal_register},
	{"unregister", luasignal_unregister},
	{"reset",      luasignal_unregister},
	{"ignore",     luasignal_ignore},
	{"check",      luasignal_check},

	{NULL, NULL} /* конец списка экспортируемых функций */
};

/* вызывается при загрузке библиотеку */
LUALIB_API int luaopen_signal(lua_State *L) {

	//luaL_openlib(L, "emilua", R, 0);
	luaL_register(L, "signal", R);

	return 1; /* завершаемся успешно */
}

