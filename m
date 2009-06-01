From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Mon, 01 Jun 2009 12:34:13 -0400
Message-ID: <4A240305.7030406@cs.columbia.edu>
References: <20090529223229.GA14536@us.ibm.com> <20090529223319.GE14602@us.ibm.com> <d4f050d30905311326i59bf5e2fjfa837f2720d076dc@mail.gmail.com> <20090601154901.GA22301@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090601154901.GA22301@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: "Andrew G. Morgan" <morgan@kernel.org>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Andrew G. Morgan (morgan@kernel.org):
>> Serge,
>>
>> I'm not sure I'm too happy with hard coding the 64-bitness of
>> capability sets. It may well be a very long time before we increase
>> their size, but couldn't you prepare for that with some reference to
>> the prevailing magic numbers for the current ABI representation?
> 
> Is the appended, updated version of the patch ok?
> 
>> Also, the use of 'error' as both a variable and a goto destination
>> looks a little confusing.
> 
> Ok, but that was in the original code.  I can send a separate
> patch for mainline to change that, but it's not hurting
> anything at the moment so not sure it's worth it?
> 
> -serge
> 
> From aa72f022fb5788ab46658e6eb94eaf18e8c6568a Mon Sep 17 00:00:00 2001
> From: Serge E. Hallyn <serue@us.ibm.com>
> Date: Mon, 11 May 2009 09:44:42 -0400
> Subject: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
> 
> An application checkpoint image will store capability sets
> (and the bounding set) as __u64s.  Define checkpoint and
> restart functions to translate between those and kernel_cap_t's.
> 
> Define a common function do_capset_tocred() which applies capability
> set changes to a passed-in struct cred.
> 
> The restore function uses do_capset_tocred() to apply the restored
> capabilities to the struct cred being crafted, subject to the
> current task's (task executing sys_restart()) permissions.
> 
> Changelog:
> 	Jun 01: Add commented BUILD_BUG_ON() to point out that the
> 		current implementation depends on 64-bit capabilities.
> 		(Andrew Morgan and Alexey Dobriyan).
> 	May 28: add helpers to c/r securebits
> 
> Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
> ---
>  include/linux/capability.h |    7 +++
>  kernel/capability.c        |  102 ++++++++++++++++++++++++++++++++++++++------
>  security/commoncap.c       |   51 +++++++++++++++-------
>  3 files changed, 130 insertions(+), 30 deletions(-)
> 
> diff --git a/include/linux/capability.h b/include/linux/capability.h
> index c302110..b3853ca 100644
> --- a/include/linux/capability.h
> +++ b/include/linux/capability.h
> @@ -536,6 +536,13 @@ extern const kernel_cap_t __cap_empty_set;
>  extern const kernel_cap_t __cap_full_set;
>  extern const kernel_cap_t __cap_init_eff_set;
>  
> +extern void checkpoint_save_cap(__u64 *dest, kernel_cap_t src);
> +struct cred;
> +extern int checkpoint_restore_cap(__u64 e, __u64 i, __u64 p, __u64 x,
> +				struct cred *cred);
> +extern void checkpoint_save_securebits(unsigned *, unsigned);
> +extern int checkpoint_restore_securebits(unsigned, struct cred *);

(nit) How about:
	checkpoint_capabilities()  or  checkpoint_cap_t()
	restore_capabilities()  or  restore_cap_t()
?  (also consistent with rest of the c/r code)

Oren.

