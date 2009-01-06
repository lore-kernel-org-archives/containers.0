From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: nfsd and containers
Date: Tue, 6 Jan 2009 10:41:59 -0500
Message-ID: <20090106154159.GC2386@fieldses.org>
References: <20090104025415.GF24075@fieldses.org>
	<20090105164016.GA8746@us.ibm.com>
	<1231196118.14345.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1231196118.14345.37.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jan 05, 2009 at 02:55:18PM -0800, Matt Helsley wrote:
> On Mon, 2009-01-05 at 10:40 -0600, Serge E. Hallyn wrote:
> > Quoting J. Bruce Fields (bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org):
> > > Does anyone have any ideas about how the kernel's nfsd should interact
> > > (if at all) with network namespaces?
> > > 
> > > I'm initially interested because I've been experimenting with modifying
> > > the server to allow it to present different exported filesystems
> > > depending on which ip address it's accessed through.  One way to do that
> > > might be by modifying the kernel to behave as though there's a separate
> > > nfsd service per network namespace; then we'd need little or no
> > > modification of the userspace support daemons (statd, the portmapper,
> > > etc.)--just start multiple instances of them in separate network
> > > namespaces and teach the kernel to route requests to them to the
> > > corresponding loopback interface.  (That would work at least for daemons
> > > that communicate with the kernel exclusively using rpc over loopback.
> > > We could perhaps do something similar with the various /proc and nfsctl
> > > interfaces.)
> 
> This sounds good. It is somewhat related to UTS namespaces because the
> hostname reported from the UTS namespace and the DNS name might not
> match. I haven't thoroughly explored all the combinations but I suspect
> the use of network namespaces could play a part in that depending on
> what choices the administrator(s) make.
> 
> > > I'm also curious more generally whether anyone's thought about how nfsd 
> > > should behave in the presence of containers.
> 
> I have only thought about how nfsd should see clients in different UTS
> and mount namespaces. The conclusion I came to was NFS should use
> whatever name was used with the original mount. So if we mounted an NFS
> export and then create a container that uses that mount then it should
> use the hostname of the original container. However if the child
> container then does another NFS mount then the child's hostname ought to
> be used for the new mount.

I'm interested in what needs to be done on the server side rather than
on the client side.  The server is perhaps less of a natural fit for the
containers project since, unlike the rest of the kernel, it doesn't
exist to perform services on behalf of local processes--it's more like a
full-blown application that happens to run inside the kernel.

Still, it might make sense to use network namespaces to implement
something like Apache's ip-based virtual hosts, by presenting the
processes in each network namespace with the illusion that they control
their own private nfs server.

On the other hand, requiring administrators to set up multiple network
namespaces just to configure this kind of nfs service may be cumbersome.

--b.
