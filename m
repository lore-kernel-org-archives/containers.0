From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Documenting reboot(2) changes for PID namespace in 3.9
Date: Thu, 14 Mar 2013 11:14:47 +0100
Message-ID: <CAKgNAkhi2qQgNfNGW8u83d7Sw_dj2F8z9CXXSOQdb4+hveZCFw__3372.7059643299$1363256140$gmane$org@mail.gmail.com>
References: <CAKgNAkg8+gx8K6W=g1LStESRO=vgtvQtt2Q-+LG5R6Tk3ncYZQ@mail.gmail.com>
	<87620xccdn.fsf@xmission.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87620xccdn.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 12, 2013 at 8:20 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
>> Li,
>>
>> Regarding your commit 923c7538236564c46ee80c253a416705321f13e3 , I
>> plan to apply the following patch to the reboot(2) manual page. Does
>> it look okay to you?
>
> You have documented the behavior as of 3.4.

Thanks Eric. I tweaked the version number.

> The change in 3.9 is to allow that same behavior in a pid_namespace
> created with a user namespace.  Aka in 3.9 the permission
> check changed from capable(CAP_SYS_BOOT)  to ns_capable(pid_ns->user_ns, CAP_SYS_BOOT);

Does anything need to be detailed about this in the man page then?

Thanks,

Michael



>
> Eric
>
>> Thanks,
>>
>> Michael
>>
>> diff --git a/man2/reboot.2 b/man2/reboot.2
>> index 8347870..1c17b85 100644
>> --- a/man2/reboot.2
>> +++ b/man2/reboot.2
>> @@ -24,7 +24,7 @@
>>  .\" Modified, 27 May 2004, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>  .\"     Added notes on capability requirements
>>  .\"
>> -.TH REBOOT 2 2010-10-31 "Linux" "Linux Programmer's Manual"
>> +.TH REBOOT 2 2013-03-12 "Linux" "Linux Programmer's Manual"
>>  .SH NAME
>>  reboot \- reboot or enable/disable Ctrl-Alt-Del
>>  .SH SYNOPSIS
>> @@ -147,6 +147,26 @@ For the i386 architecture, the additional
>> argument does not do
>>  anything at present (2.1.122), but the type of reboot can be
>>  determined by kernel command-line arguments ("reboot=...") to be
>>  either warm or cold, and either hard or through the BIOS.
>> +.SS Behavior inside PID namespaces
>> +.\" commit commit 923c7538236564c46ee80c253a416705321f13e3
>> +Since Linux 3.9, when
>                ^^^ 3.4
>> +.BR reboot ()
>> +is called from a PID namespace (see
>> +.BR pid_namespaces (7))
>> +other than the initial PID namespace,
>> +the effect of the call is to send a signal to the namespace "init" process.
>> +.BR LINUX_REBOOT_CMD_RESTART
>> +and
>> +.BR LINUX_REBOOT_CMD_RESTART2
>> +cause a
>> +.BR SIGHUP
>> +signal to be sent.
>> +.BR LINUX_REBOOT_CMD_POWER_OFF
>> +and
>> +.BR LINUX_REBOOT_CMD_HALT
>> +cause a
>> +.B SIGINT
>> +signal to be sent.
>>  .SH RETURN VALUE
>>  For the values of
>>  .I cmd



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
