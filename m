From: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Use CAP_SYS_RESOURCE as magic for escaping user
	namespaces.
Date: Tue, 7 May 2013 21:14:42 +0300
Message-ID: <CAE=NcrakiaDPRXJTQz770JNcYw9xbBJcEfCHsap-MGhkT8z2gQ@mail.gmail.com>
References: <1367913689-3423-1-git-send-email-Janne.Karhunen@gmail.com>
	<20130507171007.GB10806@austin.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130507171007.GB10806-anj0Drq5vpzx6HRWoRZK3AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, May 7, 2013 at 8:10 PM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:

> Uh, I would say nack, and if you need this then a device
> namespace allowing you to 'pass' devices similarly to how you
> pass a physical nic to a child netns is a part of the answer.

Hmm, 'slight' issue is that it does not really exist and that ns
can not even be properly specified as functionality (we tried
that earlier didn't we - everyone had different opinion on what
that ns should really do).


> Your goals are not 100% clear to me.  What is it about a user
> namespace that you want?

I'm trying to experiment with a system that has init_ns size
of one tiny task and apart from that everything runs inside
containers. Because of this I need a way to elevate rights
of certain trusted applications inside user namespaces so
that they could operate against things requesting rights
from init ns.


-- 
Janne
