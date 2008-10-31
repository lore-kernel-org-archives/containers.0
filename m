From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] rootfs automatic preparation by lxc
Date: Fri, 31 Oct 2008 14:59:47 +0100
Message-ID: <490B0F53.2000806@fr.ibm.com>
References: <200810291848.52187.dim@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810291848.52187.dim-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dmitry Mishin <dim-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, krasnov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Dmitry Mishin wrote:
> Add the ability to automatically create the container fs.
> We use OpenVZ precreated template for this - these are just regular
> tarballs with all the files required for container work. So in this
> patch we just untar it into a specified root dir (and destroy one
> after container destruction).
> 
> Signed-off-by: Sergey Krasnov <krasnov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Reviewed-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Acked-by: Dmitry Mishin <dim-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>


Thank you very much for sending this patch. The idea of retrieving 
templates from openvz and install them is good, but I don't think the 
liblxc is the right place to put this code.

IMO, that should be an external script like the debian or sshd contrib. 
Perhaps you can go further with this script and list the available 
templates you have at 
http://wiki.openvz.org/Download/template/precreated and let the user to 
choose one. If the template is not available in a cache (eg. 
/var/cache/lxc/templates), you download it. After you untar it somewhere 
and you, interactively, generate a configuration file for lxc-create 
(with the different mounts points, rootfs, network, etc ...).

> ---
> 
> --- ./src/lxc/lxc_conf.c.cache	2008-10-08 18:15:58.000000000 +0400
> +++ ./src/lxc/lxc_conf.c	2008-10-29 13:04:23.000000000 +0300
> @@ -419,27 +419,69 @@
>  	return 0;
>  }
> 
> -static int configure_rootfs(const char *name, const char *rootfs)
> +static int configure_cache(const char *name, struct lxc_conf *conf)
>  {
> +	int rc;
> +	char cmd[BUFSIZ];
>  	char path[MAXPATHLEN];
> -	char absrootfs[MAXPATHLEN];
> -	char *pwd;
> 
> -	snprintf(path, MAXPATHLEN, LXCPATH "/%s/rootfs", name);
> +	if (strlen(conf->cachefile) == 0)
> +		return 0;
> 
> -	pwd = get_current_dir_name();
> +	if (strlen(conf->rootfs) == 0) {
> +		/* special case : rootfs in container home dir */
> +		snprintf(conf->rootfs, sizeof(conf->rootfs), 
> +			LXCPATH "/%s/root", name);
> +		if (mkdir(conf->rootfs, 0755)) {
> +			lxc_log_syserror("mkdir(%s, 0755)", conf->rootfs);
> +			return -1;
> +		}
> +	}
> 
> -	snprintf(absrootfs, MAXPATHLEN, "%s/%s", pwd, rootfs);
> +	if (access(conf->rootfs, F_OK)) {
> +		lxc_log_syserror("'%s' is not accessible", conf->rootfs);
> +		return -1;
> +	}
> 
> -	free(pwd);
> +	snprintf(path, MAXPATHLEN, LXCPATH "/%s/cachefile", name);
> +	if (symlink(conf->cachefile, path)) {
> +		lxc_log_syserror("symlink(%s,%s)", conf->cachefile, path);
> +		return -1;
> +	}
> 
> -	if (access(absrootfs, F_OK)) {
> -		lxc_log_syserror("'%s' is not accessible", absrootfs);
> +	snprintf(cmd, sizeof(cmd), "tar -C %s -xzf %s", conf->rootfs, path);
> +	lxc_log_debug("system(%s)", cmd);
> +	rc = system(cmd);
> +	if (rc == -1) {
> +		lxc_log_error("system(%s) error : %m", cmd);
> +		return -1;
> +	}
> +	if (!WIFEXITED(rc)) {
> +		lxc_log_error("\"%s\" failed", cmd);
>  		return -1;
>  	}
> +	if (WEXITSTATUS(rc)) {
> +		lxc_log_error("\"%s\" return %d", cmd, WEXITSTATUS(rc));
> +		return -1;
> +	}
> +	return 0;
> +}
> +
> +static int configure_rootfs(const char *name, const char *rootfs) 
> +{
> +	char path[MAXPATHLEN];
> 
> -	return symlink(absrootfs, path);
> +	if (access(rootfs, F_OK)) {
> +		lxc_log_syserror("'%s' is not accessible", rootfs);
> +		return -1;
> +	}
> 
> +	snprintf(path, MAXPATHLEN, LXCPATH "/%s/rootfs", name);
> +	if (symlink(rootfs, path)) {
> +		lxc_log_syserror("symlink(%s,%s) : %m", rootfs, path);
> +		return -1;
> +	}
> +	return 0;
>  }
> 
>  static int configure_mount(const char *name, const char *fstab)
> @@ -574,6 +616,27 @@
>  	return 0;
>  }
> 
> +static int unconfigure_cache(const char *name)
> +{
> +	char buf[BUFSIZ];
> +	char path[MAXPATHLEN+1];
> +
> +	snprintf(path, sizeof(path), LXCPATH "/%s/rootfs", name);
> +	if (readlink(path, buf, sizeof(buf)) == -1) {
> +		lxc_log_syserror("readlink(%s)", path);
> +		return -1;
> +	}
> +	strncpy(path, buf, sizeof(path));
> +
> +	snprintf(buf, sizeof(buf), "rm -rf %s/*", path);
> +	system(buf);
> +	snprintf(path, sizeof(path), LXCPATH "/%s/root", name);
> +	rmdir(path);
> +	snprintf(path, sizeof(path), LXCPATH "/%s", name);
> +	delete_info(path, "cachefile");
> +	return 0;
> +}
> +
>  static int unconfigure_rootfs(const char *name)
>  {
>  	char path[MAXPATHLEN];
> @@ -950,9 +1013,18 @@
>  		return -1;
>  	}
> 
> -	if (conf->rootfs && configure_rootfs(name, conf->rootfs)) {
> -		lxc_log_error("failed to configure the rootfs");
> -		return -1;
> +	if (strlen(conf->cachefile)) {
> +		if (configure_cache(name, conf)) {
> +			lxc_log_error("failed to configure the cache");
> +			return -1;
> +		}
> +	}
> +
> +	if (strlen(conf->rootfs)) {
> +		if (configure_rootfs(name, conf->rootfs)) {
> +			lxc_log_error("failed to configure the rootfs");
> +			return -1;
> +		}
>  	}
> 
>  	if (conf->fstab && configure_mount(name, conf->fstab)) {
> @@ -974,6 +1046,9 @@
>  	if (conf_has_cgroup(name) && unconfigure_cgroup(name))
>  		lxc_log_error("failed to cleanup cgroup");
> 
> +	if (conf_has_cachefile(name) && unconfigure_cache(name))
> +		lxc_log_error("failed to cleanup rootfs");
> +
>  	if (conf_has_rootfs(name) && unconfigure_rootfs(name))
>  		lxc_log_error("failed to cleanup rootfs");
> 
> --- ./src/lxc/lxc_conf.h.cache	2008-10-06 22:47:19.000000000 +0400
> +++ ./src/lxc/lxc_conf.h	2008-10-29 13:04:23.000000000 +0300
> @@ -24,6 +24,7 @@
>  #define _conf_h
> 
>  #include <netinet/in.h>
> +#include <sys/param.h>
> 
>  enum { 
>  	EMPTY,
> @@ -115,7 +116,8 @@
>   * @utsname : the container utsname
>   */
>  struct lxc_conf {
> -	char *rootfs;
> +	char rootfs[MAXPATHLEN+1];
> +	char cachefile[MAXPATHLEN+1];
>  	char *fstab;
>  	struct utsname *utsname;
>  	struct lxc_list cgroup;
> @@ -145,6 +147,7 @@
> 
>  #define conf_has_fstab(__name)   conf_has(__name, "fstab")
>  #define conf_has_rootfs(__name)  conf_has(__name, "rootfs")
> +#define conf_has_cachefile(__name)  conf_has(__name, "cachefile")
>  #define conf_has_utsname(__name) conf_has(__name, "utsname")
>  #define conf_has_network(__name) conf_has(__name, "network")
>  #define conf_has_cgroup(__name) conf_has(__name, "cgroup")
> --- ./src/lxc/lxc_config.c.cache	2008-10-06 22:47:19.000000000 +0400
> +++ ./src/lxc/lxc_config.c	2008-10-29 13:04:23.000000000 +0300
> @@ -40,6 +40,7 @@
>  static int config_cgroup(const char *, char *, struct lxc_conf *);
>  static int config_mount(const char *, char *, struct lxc_conf *);
>  static int config_rootfs(const char *, char *, struct lxc_conf *);
> +static int config_cachefile(const char *, char *, struct lxc_conf *);
>  static int config_utsname(const char *, char *, struct lxc_conf *);
>  static int config_network_type(const char *, char *, struct lxc_conf *);
>  static int config_network_flags(const char *, char *, struct lxc_conf *);
> @@ -59,6 +60,7 @@
>  	{ "lxc.cgroup",         config_cgroup         },
>  	{ "lxc.mount",          config_mount          },
>  	{ "lxc.rootfs",         config_rootfs         },
> +	{ "lxc.cachefile",      config_cachefile      },
>  	{ "lxc.utsname",        config_utsname        },
>  	{ "lxc.network.type",   config_network_type   },
>  	{ "lxc.network.flags",  config_network_flags  },
> @@ -478,12 +480,43 @@
>  		lxc_log_error("%s path is too long", value);
>  		return -1;
>  	}
> +	/* if rootfs is relative path, add it on current dir */
> +	if (value[0] != '/') {
> +		char path[MAXPATHLEN+1];
> +		if (getcwd(path, sizeof(path)) == NULL) {
> +			lxc_log_error("getcwd() error : %m");
> +			return -1;
> +		}
> +		snprintf(lxc_conf->rootfs, sizeof(lxc_conf->rootfs),
> +			"%s/%s", path, value);
> +	} else {
> +		strncpy(lxc_conf->rootfs, value, sizeof(lxc_conf->rootfs));
> +	}
> 
> -	lxc_conf->rootfs = strdup(value);
> -	if (!lxc_conf->rootfs) {
> -		lxc_log_syserror("failed to duplicate string %s", value);
> +	return 0;
> +}
> +
> +static int config_cachefile(
> +		const char *key, 
> +		char *value, 
> +		struct lxc_conf *lxc_conf)
> +{
> +	if (strlen(value) >= MAXPATHLEN) {
> +		lxc_log_error("%s path is too long", value);
>  		return -1;
>  	}
> +	/* if cachefile is relative path, add it on current dir */
> +	if (value[0] != '/') {
> +		char path[MAXPATHLEN+1];
> +		if (getcwd(path, sizeof(path)) == NULL) {
> +			lxc_log_error("getcwd() error : %m");
> +			return -1;
> +		}
> +		snprintf(lxc_conf->cachefile, sizeof(lxc_conf->cachefile),
> +			"%s/%s", path, value);
> +	} else {
> +		strncpy(lxc_conf->cachefile, value, sizeof(lxc_conf->cachefile));
> +	}
> 
>  	return 0;
>  }
> @@ -577,7 +610,8 @@
> 
>  int lxc_config_init(struct lxc_conf *conf)
>  {
> -	conf->rootfs = NULL;
> +	conf->rootfs[0] = '\0';
> +	conf->cachefile[0] = '\0';
>  	conf->fstab = NULL;
>  	conf->utsname = NULL;
>  	lxc_list_init(&conf->cgroup);
> --- ./src/lxc/start.c.cache	2008-10-08 18:15:17.000000000 +0400
> +++ ./src/lxc/start.c	2008-10-29 13:04:23.000000000 +0300
> @@ -126,9 +126,11 @@
>  			return -1;
>  		}
> 
> -		if (mount(ttyname, "/dev/console", "none", MS_BIND, 0)) {
> -			lxc_log_syserror("failed to mount '/dev/console'");
> -			return -1;
> +		if (access("/dev/console", F_OK)) {
> +			if (mount(ttyname, "/dev/console", "none", MS_BIND, 0)) {
> +				lxc_log_syserror("failed to mount '/dev/console'");
> +				return -1;
> +			}
>  		}
> 
>  		/* If a callback has been passed, call it before doing exec */
> --- ./README.cache	2008-10-15 11:30:09.000000000 +0400
> +++ ./README	2008-10-29 13:04:23.000000000 +0300
> @@ -150,6 +150,10 @@
>  # the rootfs if needed for the running application
>  lxc.rootfs = /mnt/root
> 
> +# OpenVZ precreated OS template cache (see http://wiki.openvz.org , 
> +# http://wiki.openvz.org/Download/template/precreated)
> +lxc.cachefiles = /var/tmp/ubuntu-8.04-x86.tar.gz
> +
>  # The network has several of kind of configuration:
>  #
>  #  * veth : the network will use the veth virtual device, the
