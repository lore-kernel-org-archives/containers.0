From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH review 05/16] xfs: Update xfs_ioctl_setattr to handle
	projids in any user namespace
Date: Tue, 30 Jul 2013 13:57:48 +1000
Message-ID: <20130730035748.GJ21982@dastard>
References: <87txpaph4n.fsf@xmission.com>
	<1361149870-27732-1-git-send-email-ebiederm@xmission.com>
	<1361149870-27732-5-git-send-email-ebiederm@xmission.com>
	<20130219015550.GJ26694@dastard> <51F616F2.5040906@cn.fujitsu.com>
	<20130729075109.GF13468@dastard> <51F72FE6.4080202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51F72FE6.4080202-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xfs-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 30, 2013 at 11:15:50AM +0800, Gao feng wrote:
> On 07/29/2013 03:51 PM, Dave Chinner wrote:
> > http://oss.sgi.com/pipermail/xfs/2013-July/028467.html
> > 
> > Basically, the discussion we are currently having is whether project
> > IDs should be exposed to user namespaces at all. e.g:
> > 
> > http://oss.sgi.com/pipermail/xfs/2013-July/028497.html
> > http://oss.sgi.com/pipermail/xfs/2013-July/028551.html
> > 
> > "Basically, until we have worked out *if* project quotas can be used
> > safely within user namespaces, we need to reject any attempt to use
> > them from within a user namespace container."
> > 
> 
> yes, seems this v6 patchset allows user in un-init user namespace to setup proj quota
> through ioctl, and the projid hasn't been converted to kprojid in this patchset.
> Doesn't this will cause user in container has the ability to change the proj quota
> which is set by root user in host?

Dwight just posted v7. can you discuss your concerns in reposnse to
the relevant patch in that series, please? it's much easier for
everyone if we keep the discussion int eh one thread ;)

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
