From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Playing with namespaces and bloat-o-meeter
Date: Wed, 26 Sep 2007 08:45:03 -0600
Message-ID: <m1y7etv634.fsf@ebiederm.dsl.xmission.com>
References: <46FA528C.3000208@openvz.org> <46FA6AC3.6090402@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46FA6AC3.6090402-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> (Pavel Emelyanov's message of "Wed,
	26 Sep 2007 18:20:51 +0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:

>>  
>> +config NAMESPACES
>> +	bool "The namespaces support"
>> +	help
>> +	  Provides the way to make tasks work with different objects using
>> +	  the same id
>> +
>> +config NS_UTS
>> +	bool "Uname namespace"
>> +	depends on NAMESPACES
>> +	help
>> +	  The utsname namespace
>> +
>> +config NS_IPC
>> +	bool "IPC namespace"
>> +	depends on NAMESPACES && SYSVIPC
>> +	help
>> +	  The SYSVIPC ids namespaces
>> +
>> +config NS_PIDS
>> +	bool "PID namespace"
>> +	depends on NAMESPACES
>> +	help
>> +	  Tasks see only the pids living in the same namespace and in the
>> +	  child namespaces
>> +
>> +config NS_UID
>> +	bool "UID namespace"
>> +	depends on NAMESPACES && EXPERIMENTAL
>> +	help
>> +	  Support user namespaces.  This allows containers, i.e.
>> +	  vservers, to use user namespaces to provide different
>> +	  user info for different servers.  If unsure, say N.
>> +
>>  config BLK_DEV_INITRD
>>  	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
>>  	depends on BROKEN || !FRV

The reason we removed these options earlier was a maintenance issue
and the fact we could not actually compile out the namespaces.

If we don't cause maintenance complications I think the general
idea is fine.  But please.  This all should show up under
CONFIG_EMBEDDED since the only purpose is to save space.

While things are experimental there is an additional purpose of
not exposing people to broken or partially working code, so it
does make sense to have an option there.

Eric
