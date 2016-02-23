From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: call_usermodehelper in containers
Date: Tue, 23 Feb 2016 09:36:27 -0500
Message-ID: <20160223143627.GB31951__31265.3530193076$1456238536$gmane$org@fieldses.org>
References: <871u2incyo.fsf@xmission.com> <20131118172844.GA10005@redhat.com>
	<1455149857.2903.9.camel@themaw.net>
	<8737sq4teb.fsf@x220.int.ebiederm.org>
	<56C53DE3.1070108@jp.fujitsu.com>
	<1455777387.3188.24.camel@themaw.net>
	<1455781033.2908.5.camel@themaw.net>
	<87r3g9ychc.fsf@x220.int.ebiederm.org>
	<1455858850.3356.19.camel@themaw.net>
	<1456196130.2911.10.camel@themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1456196130.2911.10.camel-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Feb 23, 2016 at 10:55:30AM +0800, Ian Kent wrote:
> You know, wrt. the mechanism Oleg suggested, I've been wondering if it's
> even necessary to capture process template information for execution.
> 
> Isn't the main issue the execution of unknown arbitrary objects getting
> access to a privileged context?
> 
> Then perhaps it is sufficient to require registration of an SHA hash (of
> some sort) for these objects by a suitably privileged process and only
> allow helper execution of valid objects.

That executable probably also depends on libraries, services, and tons
of other miscellaneous stuff in its environment.  The NFSv4 client
idmapper, for example, may be doing ldap calls.  Unless the helper is
created with incredible care, I don't think that it's enough just to
verify that you're executing the correct helper.

--b.

> 
> If that is sufficient then helper execution from within a container or
> user namespace could just use the callers environment itself.
> 
> What else do we need to be wary of, any thoughts Eric?
> 
> Ian
