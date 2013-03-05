From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Pkg-shadow-devel] [PATCH 00/11] pkg-shadow support subordinate
	ids with user namespaces
Date: Tue, 5 Mar 2013 16:05:32 -0600
Message-ID: <20130305220532.GA15834@austin.hallyn.com>
References: <87d2wxshu0.fsf@xmission.com>
	<20130303153726.GA14737@austin.hallyn.com>
	<20130304055654.GE2629@mykerinos.kheops.frmug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130304055654.GE2629-FvNwPcshoeM/MCprI7ZU+I/wHUNs+SP4HZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian PERRIER <bubulle-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Cc: Nicolas =?iso-8859-1?Q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Christian PERRIER (bubulle-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org):
> Quoting Serge E. Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> > Hi Nekral,
> > 
> > This isn't a great urgency, but the final userns kernel support needed
> > for this patchset to be useful should land in 3.9, so it isn't that
> > far off.  Do you have any objections to/feedback on this set?  Would
> > this be possible to get into Debian?
> 
> 
> In Debian jessie, maybe, if someone takes shadow over....or if Nicolas
> finds some motivation and time to work again on shadow.

Is help mainly needed in bug resolution?  I'll try to help out there
(sent the trivial patch to fix one of the bugs, will email - having discussed
in irc - thoughts on another).

> In Debian wheezy, definitely no....but this is of no use, as Debian
> wheezy will certainly not use a 3.9 kernel.
> 

Right, I was only looking forward, jessie would be great.

thanks,
-serge
