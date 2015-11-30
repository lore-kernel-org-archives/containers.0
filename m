From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/8] kernfs: Add API to generate relative kernfs path
Date: Mon, 30 Nov 2015 17:53:18 -0500
Message-ID: <20151130225318.GD9039__29752.4583795623$1448924020$gmane$org@mtj.duckdns.org>
References: <1447703505-29672-1-git-send-email-serge@hallyn.com>
	<1447703505-29672-2-git-send-email-serge@hallyn.com>
	<20151124161630.GL17033@mtj.duckdns.org>
	<20151127052511.GA25490@mail.hallyn.com>
	<20151130151147.GG3535@mtj.duckdns.org>
	<20151130183758.GA25433@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151130183758.GA25433-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Serge.

On Mon, Nov 30, 2015 at 12:37:58PM -0600, Serge E. Hallyn wrote:
> > Yeah, I agree but the name is kinda misleading tho.  The output isn't
> > really a relative path but rather absolute path against the specified
> > root.  Maybe updating the function and parameter names would be
> > helpful?
> > 
> 
> Ok - updating the comment is simple enough.  Though the name/params
> kernfs_path_from_node_locked(from, to) still seem to make sense.  Would
> you prefer something like kernfs_absolute_path_from node_locked()?  I
> hesitate to call 'from' 'root' since kernfs_root is a thing and this
> is not that.

Hmmm... I see.  Let's just make sure that the comment is clear about
the fact that it calculates (pseudo) absolute path rather than
relative path.

Thanks.

-- 
tejun
