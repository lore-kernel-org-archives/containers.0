From: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Why does devices cgroup check for CAP_SYS_ADMIN explicitly?
Date: Tue, 6 Nov 2012 11:12:39 -0500
Message-ID: <20121106161238.GP14789__3553.51284747503$1352218378$gmane$org@redhat.com>
References: <20121106023845.GI19354@mtj.dyndns.org>
	<877gpzrlir.fsf@xmission.com> <20121106150131.GA14640@sergelap>
	<20121106150639.GB30069@mtj.dyndns.org>
	<20121106153032.GB18218@sergelap>
	<20121106154105.GD30069@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121106154105.GD30069-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 06, 2012 at 07:41:05AM -0800, Tejun Heo wrote:
> On Tue, Nov 06, 2012 at 09:30:32AM -0600, Serge Hallyn wrote:
> > > So, you don't really have any actual use case for the explicit CAP_*
> > > checks, right?
> > 
> > No, especially since we will now have user namespaces.
> > 
> > We will want to be able to strictly enforce hierarchical limits - i.e.
> > allow uid 100000 (which is uid 0 in the container) to change cgroup
> > settings, but never exceed limits set on the parent directory.  IIUC
> > you are working toward anyway with the general hierarchy work? (thanks
> > for that).
> 
> Yeah, I'm working toward that but I'm not sure it would mean that
> containers would be able to directly bind mount cgroupfs subdirectory
> and have free reign on it.  Maybe such thing can be made to work but I
> would be much more comfortable having something inbetween for
> impedance matching (in access policies, root cgroup behavior matching,
> whatnot).  So, the functionality will be there but it probably would
> need something inbetween if you wanna give containers control over its
> own cgroup hierarchy.
> 
> There are some issues tho.  As it currently stands, devices cgroup
> inherits configuration rather than enforcing hierarchy while checking
> for access permission.  This means that changes in an ancestor have to
> be propagated downwards and *update* configurations of descendants,
> which is what I'm working on but it can be confusing for someone
> inside the container.  Without breaking compatibility, I don't see any
> other way out tho.  I suppose it's something we'll have to live with.

yes, but most of the changes will happen before the containers start.
I've been working in a patchset (as promised) and it propagates down the
changes and also keep 'local' rules. everytime a parent change
something, the local rules are re-evaluated and reapplied if they're
still valid.

-- 
Aristeu
