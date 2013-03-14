From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: CLONE_NEWUSER|CLONE_FS root exploit
Date: Wed, 13 Mar 2013 18:48:23 -0700
Message-ID: <51412C67.30908@mit.edu>
References: <20130313175729.GH12501@outflux.net> <87r4jjkv18.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r4jjkv18.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Sebastian Krahmer <krahmer-l3A5Bk7waGM@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 03/13/2013 11:35 AM, Eric W. Biederman wrote:
> Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org> writes:
> 
>> Hi,
>>
>> It seem like we should block (at least) this combination. On 3.9, this
>> exploit works once uidmapping is added.
>>
>> http://www.openwall.com/lists/oss-security/2013/03/13/10
> 
> Yes.  That is a bad combination.  It let's chroot confuse privileged
> processes.
> 
> Now to figure out if this is easier to squash by adding a user_namespace
> to fs_struct or by just forbidding this combination.

It's worth making sure that setns(2) doesn't have similar issues.

Looking through other shared-but-not-a-namespace things, there are:

fs_struct: Buggy as noted.

files_struct: Probably harmless -- SCM_RIGHTS can emulate it

signal_struct: This interacts with the tty code.  Is it okay?

sighand_struct: Looks safe.  Famous last words.

FWIW, I've been alarmed in the past that struct path (e.g. the root
directory) implies an mnt_namespace (hidden in struct mount), and it's
entirely possible for the root directory's mnt_namespace not to match
nsproxy->mnt_namespace.  I'm not sure what the implications are, but
this doesn't seem healthy.

--Andy
