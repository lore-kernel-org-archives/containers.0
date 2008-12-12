From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] keys: play nicely with user namespaces
Date: Fri, 12 Dec 2008 11:33:12 -0600
Message-ID: <20081212173312.GA19085@us.ibm.com>
References: <20081212162220.GA15520@us.ibm.com>
	<20081212141707.GB9571@us.ibm.com>
	<20081211232323.GA8343@us.ibm.com> <3507.1229086294@redhat.com>
	<25987.1229097458@redhat.com> <26177.1229100126@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <26177.1229100126-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> > > I'm not sure, and that raises an interesting point.  How do you alter the
> > > UID and GID of keys that you're copying?  You may have a set of keys with
> > > different UIDs, for example.
> > 
> > In fact that's the expectation, else why bother creating a new user
> > namespace :)
> > 
> > Ok so my preference is to keep them segragated and always empty on
> > clone(CLONE_NEWUSER), and it sounds like that's the sanest thing right
> > now.  Please shout if I'm misunderstanding.
> 
> I think you're misunderstanding.
> 
> You can have, say, a keyring owned by UID 1, with three keys owned by UIDs 2,
> 3 and 4, respectively, and you could be, say, running as UID 5.
> 
> If you want to copy this keyring and these keys, do you just set the ownership
> of the copies to your new UID?  That might give you extra privileges.

Well no, I don't want to change any ownerships.

You're assuming I am UID 1 and own that keyring, right?  And now I do a
clone(CLONE_NEWUSER).  The new task will have UID 0 and no access to any
of those keys by virtue of being in a new user namespace.

So now, if I as UID 1 in the parent ns had access to the data loaded
into those keys, I can reload them into my new keyring.  Just as I could
do anyway.  And if I want to, since I own the new user namespace, I can
instantiate uid 2 in my new user namespace and make a key owned by UID
2.  Doesn't matter.

-serge
