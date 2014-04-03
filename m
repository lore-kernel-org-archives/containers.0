From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [GIT PULL] cgroup changes for v3.15-rc1
Date: Thu, 3 Apr 2014 11:11:20 -0700
Message-ID: <CA+55aFy1dm_CoTv+tihQ+m54G3gR9siOngurHsuKf9W3k1sKKw__3705.61093227497$1396548696$gmane$org@mail.gmail.com>
References: <20140403164911.GE24119@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140403164911.GE24119-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 3, 2014 at 9:49 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
> C3. fed95bab8d29 ("sysfs: fix namespace refcnt leak") added an
>     argument to kernfs_mount() and was routed through driver-core-next
>     after cgroup pulled the tree.  cgroup's usage needs to be updated
>     accordingly.

This one I find very annoying. There's exactly *one* user of that
interface (back in fed95bab8d29 there were none), and it doesn't want
that dummy argument.

WTF? Why did the driver-core-next development add that argument at
all, rather than just pass in NULL directly? Do we expect to grow more
users of kernfs_mount?

And the "bool *new_sb_created" argument really makes *zero* sense to
kernfs_mount(). It was added to fix a namespace refcount leak, BUT
kernfs_mount() DOES NOT TAKE A NAMESPACE PARAMETER!

So quite frankly, that kernfs_mount() calling convention change looks
completely f*cked up.

I think I'm going to resolve that conflict differently from your
suggested one - I'm going to just remove the broken stupid
"new_sb_created" argument from the kernfs_mount() helper function.

(It obviously stays around for kernfs_mount_ns() that *does* take a
namespace pointer).

People, holler if you disagree, I'll hold off pushing out my
resolution for a while anyway (do all the normal build tests and
reboot into it).

                      Linus
