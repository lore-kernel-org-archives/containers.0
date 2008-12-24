From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 3/7][v4] Define siginfo_from_ancestor_ns()
Date: Wed, 24 Dec 2008 13:24:26 -0800
Message-ID: <20081224212426.GD13502@us.ibm.com>
References: <20081224114414.GA7879@us.ibm.com>
	<20081224115124.GC8020@us.ibm.com>
	<20081224162823.GE11593@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081224162823.GE11593-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org] wrote:
| Small nit... siginfo_from_user() is only called by siginfo_from_ancestor_ns().
| The first helper depends on CONFIG_PID_NS, the second is not. A bit strange.

| 
| Isn't it cleaner to do
| 
| 	#ifdef CONFIG_PID_NS
| 	static inline int siginfo_from_user(siginfo_t *info)
| 	{
| 		...
| 	}
| 	static inline int siginfo_from_ancestor_ns(...)
| 	{
| 		...
| 	}
| 	#else
| 	static inline int siginfo_from_ancestor_ns(...)
| 	{
| 		return 0;
| 	}
| 	#endif
| 
| ?

Yes, it was that way in the earlier version, but I thought we introduced
CONFIG_PID_NS only to hide the ugliness resulting from pid-ns. Ok. I
will revert.

| 
| > +#ifdef CONFIG_PID_NS
| > +/*
| > + * siginfo_from_user() assumes that si_code SI_ASYNCIO comes only from
| > + * within the kernel. If an application is passing in SI_ASYNCIO we 
| > + * want to know about it.
| > + */
| > +static void warn_on_asyncio(siginfo_t *info)
| > +{
| > +	WARN_ON_ONCE(info->si_code == SI_ASYNCIO);
| > +}
| > +#else
| > +#define warn_on_asyncio(info)	{}
| > +#endif
| > +
| >  asmlinkage long
| >  sys_rt_sigqueueinfo(pid_t pid, int sig, siginfo_t __user *uinfo)
| >  {
| > @@ -2324,6 +2388,9 @@ sys_rt_sigqueueinfo(pid_t pid, int sig, siginfo_t __user *uinfo)
| >  	   Nor can they impersonate a kill(), which adds source info.  */
| >  	if (info.si_code >= 0)
| >  		return -EPERM;
| > +
| > +	warn_on_asyncio(&info);
| 
| Hmm... why do you want this? The user-space can use any si_code >= 0,
| why should we uglify the code?

I thought losing a SIGKILL, however twisted the path, was serious enough
to justify the ugliness. Again, I am not particular.

| 
| And, SI_ASYNCIO only matters when we send the signal to the subnamespace,
| and in that case we will probably mangle .si_pid. So why don't we warn
| when .si_code == SI_USER?

I was wondering if I should there too :-) But what do you think ? 
