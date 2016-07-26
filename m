From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Ksummit-discuss] [TECH TOPIC] Containerisation, namespaces and
	keyrings
Date: Tue, 26 Jul 2016 08:30:24 -0500
Message-ID: <20160726133024.GA2501@mail.hallyn.com>
References: <15842.1469185302@warthog.procyon.org.uk>
	<1469199065.2382.21.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1469199065.2382.21.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ikent-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ksummit-discuss-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting James Bottomley (James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org):
> On Fri, 2016-07-22 at 12:01 +0100, David Howells wrote:
> > I'm not sure this is the right venue for this, but keyrings will need 
> > to be namespaced/containerised at some point.
> 
> There are various unvirtualised subsystems within Linux.  There has
> been discussion on the containers mailing list about how:
> 
> http://thread.gmane.org/gmane.linux.kernel.containers/30371
> 
> So far Eric has advocated for making things like this properties of the
> user namespace; I'm more inclined to a separate namespace for
> delegates, but nothing's been decided.
> 
> Proposing on the containers list should be your first step (I've added
> the list to the cc).
> 
> > The problem is that it's an icky problem given that different key 
> > types really want to live in different namespaces, and upcalls may 
> > want to done in different containers, depending on the key type.
> 
> Surely if you virtualize, you'll have a namespace label per key (or
> keyring) so they'll be in one and only one namespace.
> 
> The upcall problem sounds like it might be similar to the nfsd one,
> which is nasty.  Describing it on the list would help people
> understand.
> 
> > For example, DNS resolver keys - should they be in the network, the 
> > filesystem namespace or neither?  Should the upcall be in the current 
> > container or the root container?
> 
> Depends what the upcall does.
> 
> > Authentication keys, such as used by kafs and AF_RXRPC - should they 
> > be in the filesystem namespace (kafs is an fs), the network namespace 
> > (AF_RXRPC is a net protocol) or the user namespace?
> 
> I'm sort of starting to see Eric's point now, since every namespace has
> an owning user namespace, if they were in that the question is
> naturally answered.
> 
> > Should crypto keys, such as the asymmetric key type, be in the user 
> > namespace? What about use by module signing?  Should key operations 
> > in the current container have access to a blacklist in the root 
> > container?  Should key verification in the current container have 
> > access to system keyrings?   The TPM?
> > 
> > This might actually be right for a hallway track.

Hi,

Just chiming in to say that if there were to be namespace discussion at
ksummit I'd like to be involved.  Mostly staying quiet as I don't expect
it since m-l typically works fine.

> 
> Actually, I really think this isn't a KS issue, it should be proposed
> for the Plumbers Containers MC:
> 
> http://www.linuxplumbersconf.org/2016/ocw/events/LPC2016/tracks/519
> 
> You have all the correct people in that session.  At KS you'll have 50%
> bored, 48% hostile because they hate cgroups and 2% interested.

Eh, hostile is useful - forged in the crucible and all that.

> James

-serge
