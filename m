From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Mapping PIDs from parent->child namespaces
Date: Tue, 4 Jan 2011 14:49:29 -0600
Message-ID: <20110104204929.GC3283@hallyn.com>
References: <4D225579.6030106@fesnel.com> <4D23451B.6060807@free.fr>
	<4D234E77.6000605@free.fr> <4D23806C.5040806@fesnel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D23806C.5040806-ql8fK+M3D0TQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Heffner <mikeh-ql8fK+M3D0TQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Mike Heffner (mikeh-ql8fK+M3D0TQT0dZR+AlfA@public.gmane.org):
> On 01/04/2011 11:44 AM, Cedric Le Goater wrote:

> > we use the following patch to get the pid of a task as seen from its
> > pid namespace. It can be useful to identify tasks writing pids in files.
> >
> 
> Great, I'll try it out. Has there been any interest in getting this into 
> the mainline? Are there negatives to advertising child vpid's?

I see no problems offhand with that patch.
