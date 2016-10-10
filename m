From: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH] inotify: Convert to using per-namespace limits
Date: Mon, 10 Oct 2016 18:40:46 +0200
Message-ID: <20161010164046.GG24081@quack2.suse.cz>
References: <1475837161-4626-1-git-send-email-kernel@kyup.com>
	<8737k86n7q.fsf@x220.int.ebiederm.org> <57FB38C3.9090803@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57FB38C3.9090803-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: jack-AlSwsSmVLrQ@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon 10-10-16 09:44:19, Nikolay Borisov wrote:
> On 10/07/2016 09:14 PM, Eric W. Biederman wrote:
> > Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:
> > 
> >> This patchset converts inotify to using the newly introduced
> >> per-userns sysctl infrastructure.
> >>
> >> Currently the inotify instances/watches are being accounted in the
> >> user_struct structure. This means that in setups where multiple
> >> users in unprivileged containers map to the same underlying
> >> real user (i.e. pointing to the same user_struct) the inotify limits
> >> are going to be shared as well, allowing one user(or application) to exhaust
> >> all others limits.
> >>
> >> Fix this by switching the inotify sysctls to using the
> >> per-namespace/per-user limits. This will allow the server admin to
> >> set sensible global limits, which can further be tuned inside every
> >> individual user namespace.
> >>
> >> Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
> >> ---
> >> Hello Eric, 
> >>
> >> I saw you've finally sent your pull request for 4.9 and it 
> >> includes your implementatino of the ucount infrastructure. So 
> >> here is my respin of the inotify patches using that.
> > 
> > Thanks.  I will take a good hard look at this after -rc1 when things are
> > stable enough that I can start a new development branch.
> > 
> > I am a little concerned that the old sysctls have gone away.  If no one
> > cares it is fine, but if someone depends on them existing that may count
> > as an unnecessary userspace regression.  But otherwise skimming through
> > this code it looks good.
> 
> So this indeed this is real issue and I meant to write something about
> it. Anyway, in order to preserve those sysctl what can be done is to
> hook them up with a custom sysctl handler taking the ns from the proc
> mount and the euid of current? I think this is a good approach, but
> let's wait and see if anyone will have objections to completely
> eliminating those sysctls.

Well, I believe just discarding those sysctls is not an option - I'm pretty
sure there are scripts out there which tune these sysctls and those would
stop working. IMO not acceptable regression.

								Honza
-- 
Jan Kara <jack-IBi9RG/b67k@public.gmane.org>
SUSE Labs, CR
