From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [RFC] [PATCH 5/5] cgroups: subsystem dependencies
Date: Tue, 8 Dec 2009 20:08:18 -0500
Message-ID: <20091209010817.GA8929__21108.0775400207$1260320971$gmane$org@andrew.cmu.edu>
References: <20091204085349.GA18867@andrew.cmu.edu>
	<20091204085854.GE18912@andrew.cmu.edu>
	<4B1DEE09.4010508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B1DEE09.4010508-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Dec 08, 2009 at 02:11:21PM +0800, Li Zefan wrote:
> > This patch adds a mechanism with which a subsystem can specify dependencies on
> > other subsystems. Since subsystems can come and go, it would not be useful to
> > refer to a depended-upon subsystem by subsys_id, so instead a NULL-terminated
> > array of strings must be specified. Validation is done by scanning for each
> > potential subsystem its list of subsystem names with strcmp at the end of
> > parse_cgroupfs_options.
> 
> I once posted a patch to implement this feature, but it was
> rejected by Andrew, because there was no user using it.
> 
> And still there is no user, right?

Dunno - Paul mentioned it might be useful in the future, so I threw this
together in an hour or so. Not entirely sure what he had in mind, but
this series can go with or without this particular patch.
