From: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
Subject: Re: [PATCH 1/2] coredump: use from_kuid/kgid_munged when formatting
	corename
Date: Wed, 06 May 2015 20:18:12 +0800
Message-ID: <554A0684.2000400@m4x.org>
References: <1429181404.2850.44.camel@perches.com>	<1430649246-32726-1-git-send-email-nicolas.iooss_linux@m4x.org>
	<87bnhyhm7f.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87bnhyhm7f.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 05/06/2015 03:13 AM, Eric W. Biederman wrote:
> Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org> writes:
> 
>> When adding __printf attribute to cn_printf, gcc reports some issues:
>>
>>   fs/coredump.c:213:5: warning: format '%d' expects argument of type
>>   'int', but argument 3 has type 'kuid_t' [-Wformat=]
>>        err = cn_printf(cn, "%d", cred->uid);
>>        ^
>>   fs/coredump.c:217:5: warning: format '%d' expects argument of type
>>   'int', but argument 3 has type 'kgid_t' [-Wformat=]
>>        err = cn_printf(cn, "%d", cred->gid);
>>        ^
>>
>> These warnings come from the fact that the value of uid/gid needs to be
>> extracted from the kuid_t/kgid_t structure before being used as an
>> integer.  More precisely, cred->uid and cred->gid need to be converted
>> to either user-namespace uid/gid or to init_user_ns uid/gid.
>>
>> As Documentation/sysctl/kernel.txt does not specify which user namespace
>> is used to translate %u and %g in core_pattern, but lowercase %p and %i
>> are used to format pid/tid in the current process namespace, it seems
>> intuitive that lowercase %u and %g use the current user namespace.
> 
> I love the logic of lower vs upper case letters in the selection of how
> an identifier should be used.  Unfortunately I can't support it.
> 
> Converting to anything other than init_user_ns will actually be an ABI
> break.  Which in practice should trump everything else.

I agree.  Initially I thought that my patch introduced only a minor
change to make the ABI more consistent, but if you think this change is
actually large enough to be considered a "not-wanted ABI break", I will
follow your decision.

> Further only the global root user can set this value, which largely
> implies that the program setting the core dump patter will expect the
> values to be in the initial user namespace.

Ok, I missed this.  The main source of my confusion is that the coredump
uses the current mount namespace to create files (I tested using a
Docker container with core_pattern set to something in /tmp) and the
global process/mount namespaces when using pipes (tested with
systemd-coredump).

> In practice your patch allows any user to put any uid they want on core
> files which seems to make the uid parameter useless.
> 
> So for all of the reasons above I think we need to print uids and gids
> in the initial user namespace unless explicitly requested to do so.

So be it.  I'll update my patches and send them again.  In order to make
things clearer, I also would like to modify the documentation of %u and
%g, with something like:

--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -197,8 +197,8 @@
 	%P	global pid (init PID namespace)
 	%i	tid
 	%I	global tid (init PID namespace)
-	%u	uid
-	%g	gid
+	%u	uid (in init user namespace)
+	%g	gid (in init user namespace)
 	%d	dump mode, matches PR_SET_DUMPABLE and
 		/proc/sys/fs/suid_dumpable
 	%s	signal number

Would such a change be accepted, and if yes is it better to put it in
its own commit or in the same as the one modifying the code?

Thanks,

Nicolas
