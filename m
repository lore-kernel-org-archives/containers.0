From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] ioctl_tty.2: add TIOCGPTPEER documentation
Date: Thu, 17 Aug 2017 02:54:03 +1000
Message-ID: <a7175aad-645c-8f86-d7cf-51f24f0bc281__43497.5361488343$1502902465$gmane$org@suse.de>
References: <20170609170147.32311-1-asarai@suse.de>
	<11706e49-8271-ed8c-3747-19b3e8f2850d@gmail.com>
	<878tijwjic.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <878tijwjic.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

> A couple of things to note on the bigger picture.
> 
> The glibc library on all distributions has been changed to not have a
> setuid binary pt_chown, that uses ptsname.  This was the primary fix
> for the security issue.
> 
> The behavior of opening /dev/ptmx has been changed to perform a path
> lookup relative to the location of /dev/ptmx of  ./pts/ptmx and open
> it it is a devpts filesystem and to fail otherwise.    This further
> makes it hard to confuse userspace this way as /dev/ptmx always
> corresponds to /dev/pts/ptmx.  Even in chroots and in other mount
> namespaces.

I have a feeling that there might be a way to trick glibc if you use 
FUSE, but I haven't actually tried to create a PoC for it. Fair point 
though.

> That makes TIOCGPTPEER a very nice addition, but not something people
> have to scramble to use to ensure their system is secure.  As a hostile
> environment now has to work very hard to confuse the existing mechanisms.

There are usecases where you simply need TIOCGPTPEER, and no other 
userspace alternative will do, but maybe if we modified the paragraph to 
read (as suggested):

   Security-conscious programs interacting with namespaces may
   wish  to  use  this  operation rather than open(2) with the
   pathname returned by ptsname(3).

This would clarify that there are usecases where you need this 
particular feature, without saying causing people to panic over 
inaccurate claims of glibc being broken. Does that sound better?

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
