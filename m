From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] cgroup changes for v3.15-rc1
Date: Thu, 03 Apr 2014 16:18:03 -0700
Message-ID: <87bnwic89g.fsf__18884.2858108275$1396567112$gmane$org@x220.int.ebiederm.org>
References: <20140403164911.GE24119@htj.dyndns.org>
	<CA+55aFy1dm_CoTv+tihQ+m54G3gR9siOngurHsuKf9W3k1sKKw@mail.gmail.com>
	<CA+55aFwBm202pchEH9A6vbJVdar9-T35pBF44cCt7FNjmno9sQ@mail.gmail.com>
	<CAOS58YMckmoCocguf9BC_Wxbn3D2Rx3MArhgozO9qCj4g=5aDw@mail.gmail.com>
	<CA+55aFw2+VKojzoF2aDaruOMKHikTO8J0HeK9DoDLZr+HqTWbg@mail.gmail.com>
	<20140403194335.GC2472@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140403194335.GC2472-9pTldWuhBndy/B6EtB590w@public.gmane.org> (Tejun Heo's message of
	"Thu, 3 Apr 2014 15:43:35 -0400")
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:

> Hello,
>
> On Thu, Apr 03, 2014 at 12:01:23PM -0700, Linus Torvalds wrote:
>> [ Extending the participants list a bit ]
>> 
> As for using specific type for ns tag, yeah, that'd be better
> regardless of this.  The opaqueness is a bit extreme now.

(The opaqueness has alwasy been silly but it was the compromise
 required to get the code merged.  Sigh)

With respect to cleaning up the namespace opaqueue pointers while
working on the sysctls I came up with a design that is quite a bit
more maintainable.

The basic idea in terms of kernfs is to have an array (sized 1 for now)
in the superblock of pointers to root kernfs_nodes.  Then you have a
nslink node type that holds the index of the kernfs_node pointer it is
associated with.  When following a nslink (which is unconditional
because they would not be visible to userspace) the appropriate root
kernfs_node is selected from the superblock and traversed to the same
path as the nslink.

The major benefit is that except for special cases in mounting (to
populate the extra root), and following the nslink there is no extra
logic to worry about or deal with.

Since that winds up using ordinary kernfs_nodes, which are already
reference counted in a well understood way we should be able to
completely remove passive refcount to the network namespace.

Since it has been clear what is needed for 3.15 and for resolving the
merge conflict I am not suggesting we do anything this merge window but
since we are talking about how to clean up warts in the existing design,
I figured I should mention it.

Eric
