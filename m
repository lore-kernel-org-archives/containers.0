From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH review 10/16] xfs: Push struct kqid into
	xfs_qm_scall_qmlim and xfs_qm_scall_getquota
Date: Tue, 19 Feb 2013 13:27:07 +1100
Message-ID: <20130219022707.GL26694@dastard>
References: <87txpaph4n.fsf@xmission.com>
	<1361149870-27732-1-git-send-email-ebiederm@xmission.com>
	<1361149870-27732-10-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1361149870-27732-10-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Feb 17, 2013 at 05:11:03PM -0800, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> - In xfs_qm_scall_getquota map the quota id into the callers
>   user namespace in the returned struct fs_disk_quota
> 
> - Add a helper is_superquota and use it in xfs_qm_scall_setqlimi
>   to see if we are setting the superusers quota limit.  Setting
>   the superuses quota limit on xfs sets the default quota limits
>   for all users.

These seem fine.

> - Move xfs_quota_type into xfs_qm_syscalls.c where it is now used.

Now that I've seen the code, I really don't see any advantage to
driving the kqid into XFS quota subsystem. (i.e the rest of this
patch and the subsequent follow up patches that drive it further
inward).

I did say previously:

>> From there, targetted patches can drive the kernel structures
>> inward from the entry points where it makes sense to do so (e.g.
>> common places that the quota entry points call that take a
>> type/id pair).  The last thing that should happen is internal
>> structures be converted from type/id pairs to the kernel types if
>> it makes sense to do so and it makes the code simpler and easier
>> to read....

But seeing the result, IMO, it doesn't actually improve the code
(it's neither simpler nor easier to read), and it doesn't actually
add any functionality. It makes the code strange and different and
somewhat inconsistent and litters id/namespace conversions all over
the place, so i don't think these cahgnes are necessary.

Hence I'd say just do absolute minimum needed for the
is_superquota() checks to work and leave all the kqid ->
xfs_dqid_t+type conversion at the boundary of the quota subsystem
where it already is....

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
