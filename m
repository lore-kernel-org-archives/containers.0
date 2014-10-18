From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: How to use cgroups within containers?
Date: Sat, 18 Oct 2014 05:50:12 +0200
Message-ID: <20141018035012.GA16300@mail.hallyn.com>
References: <CAFLxGvxzmfhLZPsmsFG9qdB0oDf9ayvNaWNNOXqcAkW3yATffg@mail.gmail.com>
	<CAFLxGvxKP2wkGOqW=mz7Sv=+yJXiY-1Hz-4kKfR8mYVEWPOj6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAFLxGvxKP2wkGOqW=mz7Sv=+yJXiY-1Hz-4kKfR8mYVEWPOj6Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org" <systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Richard Weinberger (richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> ...fixing LXC devel mailinglist... :-\
> 
> On Fri, Oct 17, 2014 at 11:35 PM, Richard Weinberger
> <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Dear systemd and container folks,
> >
> > at Plumbers the question raised how to provide cgroups to a systemd that lives
> > in a container (with user namespaces).
> > Due to the GDL train strikes I had to leave very soon and had no chance to
> > talk to you in person.
> >
> > Was a solution proposed?
> > All I want to know is how to provide cgroups in a sane and secure way
> > to systemd. :-)

My takeaway from the discussion was that there was general agreement that
the cgroup namespaces patches posted by Aditya Kali would solve the
problem.

-serge
