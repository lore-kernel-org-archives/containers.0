From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: nfsd and containers
Date: Mon, 05 Jan 2009 14:55:18 -0800
Message-ID: <1231196118.14345.37.camel@localhost>
References: <20090104025415.GF24075@fieldses.org>
	<20090105164016.GA8746@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090105164016.GA8746-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2009-01-05 at 10:40 -0600, Serge E. Hallyn wrote:
> Quoting J. Bruce Fields (bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org):
> > Does anyone have any ideas about how the kernel's nfsd should interact
> > (if at all) with network namespaces?
> > 
> > I'm initially interested because I've been experimenting with modifying
> > the server to allow it to present different exported filesystems
> > depending on which ip address it's accessed through.  One way to do that
> > might be by modifying the kernel to behave as though there's a separate
> > nfsd service per network namespace; then we'd need little or no
> > modification of the userspace support daemons (statd, the portmapper,
> > etc.)--just start multiple instances of them in separate network
> > namespaces and teach the kernel to route requests to them to the
> > corresponding loopback interface.  (That would work at least for daemons
> > that communicate with the kernel exclusively using rpc over loopback.
> > We could perhaps do something similar with the various /proc and nfsctl
> > interfaces.)

This sounds good. It is somewhat related to UTS namespaces because the
hostname reported from the UTS namespace and the DNS name might not
match. I haven't thoroughly explored all the combinations but I suspect
the use of network namespaces could play a part in that depending on
what choices the administrator(s) make.

> > I'm also curious more generally whether anyone's thought about how nfsd 
> > should behave in the presence of containers.

I have only thought about how nfsd should see clients in different UTS
and mount namespaces. The conclusion I came to was NFS should use
whatever name was used with the original mount. So if we mounted an NFS
export and then create a container that uses that mount then it should
use the hostname of the original container. However if the child
container then does another NFS mount then the child's hostname ought to
be used for the new mount.

> I suspect Eric has had more detailed thoughts than I so I'm waiting
> to see his response.  Matt sent a patchset to deal with sunrpc/nfs/uts
> namespaces which I haven't yet had a chance to look at, so he might
> also have some good comments at this point.

Seems there's some confusion -- that patchset went out privately during
the holidays. Now is a good time to repost it publicly though. I'll cc
folks on this thread. I'm also planning on cc'ing nfs-devel to get their
thoughts.

Cheers,
	-Matt Helsley
