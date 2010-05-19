From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: NFS Kernel server inside a container
Date: Wed, 19 May 2010 10:45:38 -0500
Message-ID: <20100519154538.GA18057@us.ibm.com>
References: <4BF3B677.7080601@free.fr>
	<516306.35958.qm@web36107.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <516306.35958.qm-xC2hcER8YRCvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Martin Fick <mogulguy-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Martin Fick (mogulguy-/E1597aS9LQAvxtiuMwx3w@public.gmane.org):
> --- On Wed, 5/19/10, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
> It sounds like you did an NFS client mount inside a
> container. I am actually trying to do the reverse, I
> would like to do kernel server exports from within
> a container.  Specifically, I would like to have
> several data partitions replicated with drbd and to
> be able to export these partitions via NFS 
> independently from different containers with
> different IPs.  
> 
> So, for example, from 2 hosts, I might have 6 NFS 
> partitions to export and during normal operation
> I would expect each host to make 3 of the 
> partitions primary via drbd and to then to
> each launch three containers each with separate 
> IPs which will individually export the 3 different 
> drbd partitions via NFS.  For failover or load 
> balancing, it should then be able to shut down
> any individual container on one host and bring it
> up on the other host without affecting the other
> exports.
> 
> Thanks,
> 
> -Martin

You'll need to use a userspace NFS server.  Something like
http://unfs3.sourceforge.net/.  Certainly looks...  venerable.

-serge
