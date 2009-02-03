From: Bill Nottingham <notting-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup mount point
Date: Tue, 3 Feb 2009 11:19:49 -0500
Message-ID: <20090203161949.GB32677@nostromo.devel.redhat.com>
References: <20090202200013.GU3643@vespa.holoscopio.com>
	<1233606371.15779.32.camel@radis.liafa.jussieu.fr>
	<20090202205246.GA28593@glandium.org>
	<20090202214153.GV3643@vespa.holoscopio.com>
	<20090203102416.GA8886@redhat.com>
	<20090203150315.GI482@boogie.lpds.sztaki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090203150315.GI482-WfxVeM0IB4OcrO3FVCo2em/Xy1I+TMuj@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gabor Gombas <gombasg-SuEj7oiQppWHXe+LvDLADg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, debian-devel-0aAXYlwwYIJuHlm7Suoebg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Gabor Gombas (gombasg-SuEj7oiQppWHXe+LvDLADg@public.gmane.org) said: 
> On Tue, Feb 03, 2009 at 10:24:16AM +0000, Daniel P. Berrange wrote:
> 
> > Putting new mount points in / is not really acceptable, so that rules
> > out the first two. /opt is just totally wrong, since that is intended
> > for add on software packages. /dev/ feels a little odd, since it is
> > not really device nodes, but perhaps that doesn't matter. So my pref
> > would be something in /dev/cgroups or /sys/cgroups
> 
> How about /var/lib/cgroup? There's already precedent
> (/var/lib/nfs/rpc_pipefs) of mounting virtual file systems under
> /var/lib.

Depending on when you need the cgroup filesystem to setup your
containers, /var may not be there.

Bill
