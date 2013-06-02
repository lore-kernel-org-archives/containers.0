From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Pkg-shadow-devel] [PATCH 00/11] pkg-shadow support subordinate
	ids with user namespaces
Date: Sun, 2 Jun 2013 08:48:23 -0500
Message-ID: <20130602134823.GB8004@austin.hallyn.com>
References: <87d2wxshu0.fsf@xmission.com> <20130307102352.4a5943cd@oracle.com>
	<20130307215457.GB9348@austin.hallyn.com>
	<876212rf9b.fsf@xmission.com>
	<20130308065019.GI5885@mykerinos.kheops.frmug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130308065019.GI5885-FvNwPcshoeM/MCprI7ZU+I/wHUNs+SP4HZ5vskTnxNA@public.gmane.org>
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
Cc: Nicolas Fran??ois <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Christian PERRIER (bubulle-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org):
> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> 
> > Yes.  It looks like we are going to have to setup a public repository
> > somewhere to collect all of the changes and bug fixes.  Not that I
> > expect too many but clearly there are a few needed.
> 
> That exists.
> 
> Shadow upstream (and Debian package) is maintained in an SVN
> repository hosted on alioth.debian.org.
> 
> I can make it as easy as possible to people to contribute by opening
> commit access there.
> 
> We can also, if that helps in attracting contributors, convert the
> repo to git (I will need help there because the repo has a quite long
> history and we want to keep it). I know that, nowadays, svn often

Hi,

I've not used svn at all, but would it help if I take a shot at this
conversion (maintaining full history) putting the result into github
for a first run?

-serge
