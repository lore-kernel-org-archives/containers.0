From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: Playing with namespaces and bloat-o-meeter
Date: Wed, 26 Sep 2007 18:49:42 +0400
Message-ID: <46FA7186.1070202@openvz.org>
References: <46FA528C.3000208@openvz.org> <46FA6AC3.6090402@openvz.org>
	<m1y7etv634.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1y7etv634.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
> 
>>>  
>>> +config NAMESPACES
>>> +	bool "The namespaces support"
>>> +	help
>>> +	  Provides the way to make tasks work with different objects using
>>> +	  the same id
>>> +
>>> +config NS_UTS
>>> +	bool "Uname namespace"
>>> +	depends on NAMESPACES
>>> +	help
>>> +	  The utsname namespace
>>> +
>>> +config NS_IPC
>>> +	bool "IPC namespace"
>>> +	depends on NAMESPACES && SYSVIPC
>>> +	help
>>> +	  The SYSVIPC ids namespaces
>>> +
>>> +config NS_PIDS
>>> +	bool "PID namespace"
>>> +	depends on NAMESPACES
>>> +	help
>>> +	  Tasks see only the pids living in the same namespace and in the
>>> +	  child namespaces
>>> +
>>> +config NS_UID
>>> +	bool "UID namespace"
>>> +	depends on NAMESPACES && EXPERIMENTAL
>>> +	help
>>> +	  Support user namespaces.  This allows containers, i.e.
>>> +	  vservers, to use user namespaces to provide different
>>> +	  user info for different servers.  If unsure, say N.
>>> +
>>>  config BLK_DEV_INITRD
>>>  	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
>>>  	depends on BROKEN || !FRV
> 
> The reason we removed these options earlier was a maintenance issue
> and the fact we could not actually compile out the namespaces.

I do not propose to compile out the namespaces, I just propose
to compile out the code that does the clone and release of new
namespaces. This is absolutely painless.

> If we don't cause maintenance complications I think the general
> idea is fine.  But please.  This all should show up under
> CONFIG_EMBEDDED since the only purpose is to save space.

Hm... Ok, but I also try to save the vmlinux size on my home
PC, so I'd be happy if I could just throw these things out.

Anyway - I will move the CONFIG_NAMESPACES to be selectable
with the EMBEDDED only.

> While things are experimental there is an additional purpose of
> not exposing people to broken or partially working code, so it
> does make sense to have an option there.

Ok, thanks.

So your accolades, can they be transformed into Acked-by-s or
just mentioned in the patch like "reviewed and approved by ..."?

> Eric
> 
