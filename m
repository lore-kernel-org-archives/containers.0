From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] userns: honour no_new_privs for cap_bset during user ns
	creation/switch
Date: Fri, 22 Dec 2017 02:03:35 +0100
Message-ID: <CAHo-OoyrOr5jXwU-j4Z4qYdWo40+qAdAk0r+OpfMUZ6LgbS-RA__47676.4073050164$1513904527$gmane$org@mail.gmail.com>
References: <20171221210605.181720-1-zenczykowski@gmail.com>
	<87wp1foiwa.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87wp1foiwa.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mahesh Bandewar <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Dec 21, 2017 at 10:44 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> No.  This makes no logical sense.
>
> A task that enters a user namespace loses all capabilities to everything
> outside of the user namespace.  Capabilities inside a user namespace are
> only valid for objects created inside that user namespace.
>
> So limiting capabilities inside a user namespace when the capability
> bounding set is already fully honored by not giving the processes any of
> those capabilities makes no logical sense.
>
> If the concern is kernel attack surface versus logical permissions we
> can look at ways to reduce the attack surface but that needs to be fully
> discussed in the change log.

Here's an example of using user namespaces to read a file you
shouldn't be able to.

lpk19:~# uname -r
4.15.0-smp-d1ce8ceb8ba8

(we start as true global root)
lpk19:~# id
uid=0(root) gid=0(root) groups=0(root)

(cleanup after previous run)
lpk19:~# cd /; chattr -i /immu; rm -f /immu/log; rmdir /immu

(now we create an append only logfile owned by target user:group)
lpk19:~# cd /; mkdir /immu; touch /immu/log; chown produser:prod
/immu/log; chmod a-rwx,u+w /immu/log; chattr +a /immu/log

(let's show what things look like)
lpk19:~# chattr +i /immu; ls -ld / /immu /immu/log; lsattr -d / /immu /immu/log
drwxr-xr-x 22 root root 4096 Dec 21 16:33 /
drwxr-xr-x 2 root root 4096 Dec 21 16:23 /immu
--w------- 1 produser prod 0 Dec 21 16:23 /immu/log
-----------I--e---- /
----i---------e---- /immu
-----a--------e---- /immu/log

(the immutable bit prevents us from changing permissions on the file)
lpk19:/# chmod a+rwx /immu/log
chmod: changing permissions of '/immu/log': Operation not permitted

(the append only bit prevents us from simply overwriting the file)
lpk19:/# echo log1 > /immu/log
-bash: /immu/log: Operation not permitted

(but we can append to it)
lpk19:/# echo log1 >> /immu/log

(we're global root with CAP_DAC_OVERRIDE, so we can *still* read it)
lpk19:/# cat /immu/log
log1

(let's transition to target user)
lpk19:/# su - produser

produser@lpk19:~$ id
uid=2080(produser) gid=620(prod) groups=620(prod)

(we can't overwrite it)
produser@lpk19:~$ echo log2 > /immu/log
-su: /immu/log: Operation not permitted

(but we can log to it: as intended)
produser@lpk19:~$ echo log2 >> /immu/log

(we can't change its permissions, cause it's in an immutable directory)
produser@lpk19:~$ chmod u+r /immu/log
chmod: changing permissions of '/immu/log': Operation not permitted

(we can't dump the file, cause we don't have CAP_DAC_OVERRIDE)
produser@lpk19:~$ cat /immu/log
cat: /immu/log: Permission denied

(or can we?)
produser@lpk19:~$ unshare -U -r cat /immu/log
log1
log2

----

Now, of course, the above patch doesn't actually fix this on it's own,
since 'su' doesn't (yet?) know to restrict bset or to set
no_new_privs.

But: it allows the sandbox equivalent of su to drop CAP_DAC_OVERRIDE
from it's inh/eff/perm/ambient/bset, and set no_new_privs.
Now the unshare won't gain CAP_DAC_OVERRIDE and won't be able to cat
the non-readable append-only log file.

IMHO the point of having a capability bounding set and/or no_new_privs
is to never be able to regain capabilities.
Note also that 'no_new_privs' isn't cleared across a
unshare(CLONE_NEWUSER) [presumably also applies to setns()].

We can of course argue the implementation details (for example instead
of using the existing no_new_privs flag, add a new
keep_bset_across_userns_transitions securebits flag)... but
*something* has to be done.

- Maciej
