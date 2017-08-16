From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] ioctl_tty.2: add TIOCGPTPEER documentation
Date: Wed, 16 Aug 2017 12:14:37 -0500
Message-ID: <87ziaztoxu.fsf__32701.5140712776$1502903708$gmane$org@xmission.com>
References: <20170609170147.32311-1-asarai@suse.de>
	<11706e49-8271-ed8c-3747-19b3e8f2850d@gmail.com>
	<878tijwjic.fsf@xmission.com>
	<a7175aad-645c-8f86-d7cf-51f24f0bc281@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <a7175aad-645c-8f86-d7cf-51f24f0bc281-l3A5Bk7waGM@public.gmane.org> (Aleksa Sarai's
	message of "Thu, 17 Aug 2017 02:54:03 +1000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org> writes:

>> A couple of things to note on the bigger picture.
>>
>> The glibc library on all distributions has been changed to not have a
>> setuid binary pt_chown, that uses ptsname.  This was the primary fix
>> for the security issue.
>>
>> The behavior of opening /dev/ptmx has been changed to perform a path
>> lookup relative to the location of /dev/ptmx of  ./pts/ptmx and open
>> it it is a devpts filesystem and to fail otherwise.    This further
>> makes it hard to confuse userspace this way as /dev/ptmx always
>> corresponds to /dev/pts/ptmx.  Even in chroots and in other mount
>> namespaces.
>
> I have a feeling that there might be a way to trick glibc if you use
> FUSE, but I haven't actually tried to create a PoC for it. Fair point
> though.

To trick glibc fuse would have to be mounted somewhere on /dev.

>> That makes TIOCGPTPEER a very nice addition, but not something people
>> have to scramble to use to ensure their system is secure.  As a hostile
>> environment now has to work very hard to confuse the existing mechanisms.
>
> There are usecases where you simply need TIOCGPTPEER, and no other
> userspace alternative will do, but maybe if we modified the paragraph
> to read (as suggested):
>
>   Security-conscious programs interacting with namespaces may
>   wish  to  use  this  operation rather than open(2) with the
>   pathname returned by ptsname(3).
>
> This would clarify that there are usecases where you need this
> particular feature, without saying causing people to panic over
> inaccurate claims of glibc being broken. Does that sound better?

I think your original words sounded fine.  I would even go for new
programs may want to use the new ioctl as it fundamentally less racy
and more of what is actually trying to be implemented with the userspace
pieces.

I just wanted to point out that TIOCGPTPEER while being the interface
that it would have been nice had we had since the beginning (and would
have avoided all of the problems) is actually not something we need to
scramble and use it is just a very nice to have.  As the immediate
issues have been fixed in other ways.    It was not clear to me from the
other discussions if you and Michael Kerrisk were aware of the
mitigations that had been made to address the security issue.

The change to the behavior of /dev/ptmx may need to be documented
somewhere.   I am not certain if anything has been documented since
devpts has started allowing multiple mounts.

Eric
