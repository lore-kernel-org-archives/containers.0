From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] keys: play nicely with user namespaces
Date: Fri, 12 Dec 2008 10:22:20 -0600
Message-ID: <20081212162220.GA15520@us.ibm.com>
References: <20081212141707.GB9571@us.ibm.com>
	<20081211232323.GA8343@us.ibm.com> <3507.1229086294@redhat.com>
	<25987.1229097458@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <25987.1229097458-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > I guess the question is what sorts of keys would you want a child
> > user-namespace to inherit (that perhaps it couldn't)?  The primary
> > ones I can think of are keys for an encrypted fs.
> 
> Yeah.  But it can always ask for them.
> 
> > Are there any sorts of keys X uses?
> 
> Not at the moment.
> 
> > Anyway if this set of patches does the segration correctly, I can float
> > a patch on top of these to copy the keyrings.
> 
> Each key type would need to provide an operation for copying its keys.
> 
> > But should the (automatic in-kernel) copy then still go through the security
> > checks?  (If not, is that safe, and if so, is there any advantage?)
> 
> I'm not sure, and that raises an interesting point.  How do you alter the UID
> and GID of keys that you're copying?  You may have a set of keys with
> different UIDs, for example.

In fact that's the expectation, else why bother creating a new user
namespace :)

Ok so my preference is to keep them segragated and always empty on
clone(CLONE_NEWUSER), and it sounds like that's the sanest thing right
now.  Please shout if I'm misunderstanding.

> > Do you have an automated testsuite for the keyrings?  I just played
> > around with keyctl to test, since there was nothing in ltp.
> 
> Yes.
> 
> 	http://people.redhat.com/~dhowells/keys/keyutils/keyutils-tests.tar.bz2
> 
> which may need:
> 
> 	http://people.redhat.com/~dhowells/keys/keyutils/rhts_environment.sh
> 
> The tests are designed to run under RH's automated test environment.  All my
> tests are shell scripts that wrap the keyctl program.

Cool, thanks, I'll test with those.

-serge
