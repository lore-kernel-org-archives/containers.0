From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC][PATCH] locks: Allow disabling mandatory locking at compile
	time
Date: Wed, 11 Nov 2015 20:33:11 -0500
Message-ID: <20151112013311.GA32064__23932.3954484009$1447292011$gmane$org@fieldses.org>
References: <876118v333.fsf@x220.int.ebiederm.org>
	<20151111202607.GD29410@fieldses.org>
	<20151111174401.5778153c@tlielax.poochiereds.net>
	<876118ruiu.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <876118ruiu.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 11, 2015 at 05:22:33PM -0600, Eric W. Biederman wrote:
> Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org> writes:
> 
> > On Wed, 11 Nov 2015 15:26:07 -0500
> > "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> wrote:
> >
> >> On Wed, Nov 11, 2015 at 11:49:20AM -0600, Eric W. Biederman wrote:
> >> > 
> >> > Mandatory locking appears to be almost unused and buggy and there
> >> > appears no real interest in doing anything with it.  Since effectively
> >> > no one uses the code and since the code is buggy let's allow it to be
> >> > disabled at compile time.  I would just suggest removing the code but
> >> > undoubtedly that will break some piece of userspace code somewhere.
> >> > 
> >> > For the distributions that don't care about this piece of code
> >> > this gives a nice starting point to make mandatory locking go away.
> >> > 
> >> > Cc: Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >> > Cc: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> >> > Cc: Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
> >> > Cc: J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> >> > Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> >> > ---
> >> > 
> >> > A piece of userspace software having problematic interactions with
> >> > mandatory locking recently came up as an issue
> >> 
> >> Is there any more interesting story there?
> 
> Only that I overlooked them when implementing user namespace support for
> mounting filesystems so it is currently possible to without privilege to
> mount tmpfs with mandatory locking enabled and pass a file descriptor to
> a daemon that was not expecting them.  Causing nice denial of service
> attacks.
> 
> So I need to decide what to do with mandatory locking in user
> namespaces.
> 
> As the consensus of this thread is that users of mandatory locking are
> as rare as hen's teeth I can just not allow mandatory locking if you
> something is being mounted just user namespace permissions.

Sounds like a plan.  If nobody notices this limitation then that's
further evidence that we might be able to get away with deprecating it
eventually.

(Well, I wouldn't be surprised if there's some test suite somewhere that
includes a simple test for mandatory lock enforcement.  So, any user
other than that....)

--b.
