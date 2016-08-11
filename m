From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] kernel: show current values of ucounts
Date: Thu, 11 Aug 2016 15:15:34 -0500
Message-ID: <20160811201533.GA712@mail.hallyn.com>
References: <1470898933-5336-1-git-send-email-avagin@openvz.org>
	<CAGXu5j+foRDQqe9vTfB1KnE1WZBODFfQz=fUa_kq009uR2i-ng@mail.gmail.com>
	<20160811195725.GA12438@outlook.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160811195725.GA12438-1ViLX0X+lBJGNQ1M2rI3KwRV3xvJKrda@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Andrei Vagin (avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org):
> On Thu, Aug 11, 2016 at 12:05:12PM -0700, Kees Cook wrote:
> > On Thu, Aug 11, 2016 at 12:02 AM, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> > > This patch adds /proc/ucounts where all non-zero ucounts for a current
> > > userns are shown.
> > 
> > Eric would have a better sense of this, but I think we would normally
> > avoid putting something in the top-level /proc directory, especially
> > for namespace things (which IIUC usually appear in /proc/$pid/ns/).
> 
> /proc/$pid/ns contains links to namespaces handles. I am not sure that
> it's a good place for this file.
> 
> And I'm agree that it may be a good idea to move this file to
> /proc/$pid/.  It's like /proc/PID/net.
> 
> In thise case we will not need to switch into a user namespace to get
> its ucounts.
> 
> > 
> > Also, this should describe what ucounts are for people unfamiliar with
> > them. (i.e. this commit message doesn't really contain a detailed
> > description of what's being added.)
> > 
> > And finally, any changes to /proc need an associated entry in
> > Documentation/filesystems/proc.txt
> 
> I will add documentation and a better description for this patch.
> 
> Thank you for the comments.

I'd also use a more descriptive name - /proc/pid/userns_counts?
ucounts makes me think microcounts.
