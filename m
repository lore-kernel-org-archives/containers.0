From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH ghak32 V2 01/13] audit: add container id
Date: Fri, 18 May 2018 11:21:06 -0400
Message-ID: <20180518152106.do5b3mu6e6eyvo7q__24713.4710815319$1526656840$gmane$org@madcap2.tricolour.ca>
References: <cover.1521179281.git.rgb@redhat.com>
	<e284617ad667ad8f17958dd8babb87fe1b4d7205.1521179281.git.rgb@redhat.com>
	<20180517170053.7d4afa87@ivy-bridge>
	<20180517215600.dyswlkvqdtgjwr5y@madcap2.tricolour.ca>
	<20180518095636.56ff322d@ivy-bridge>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20180518095636.56ff322d@ivy-bridge>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
List-Id: containers.vger.kernel.org

On 2018-05-18 09:56, Steve Grubb wrote:
> On Thu, 17 May 2018 17:56:00 -0400
> Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > > During syscall events, the path info is returned in a a record
> > > simply called AUDIT_PATH, cwd info is returned in AUDIT_CWD. So,
> > > rather than calling the record that gets attached to everything
> > > AUDIT_CONTAINER_INFO, how about simply AUDIT_CONTAINER.  
> > 
> > Considering the container initiation record is different than the
> > record to document the container involved in an otherwise normal
> > syscall, we need two names.  I don't have a strong opinion what they
> > are.
> > 
> > I'd prefer AUDIT_CONTAIN and AUDIT_CONTAINER_INFO so that the two
> > are different enough to be visually distinct while leaving
> > AUDIT_CONTAINERID for the field type in patch 4 ("audit: add
> > containerid filtering")

(Sorry, I had intended AUDIT_CONTAINER for the first in that paragraph
above.)

> How about AUDIT_CONTAINER for the auxiliary record? The one that starts
> the container, I don't have a strong opinion on. Could be
> AUDIT_CONTAINER_INIT, AUDIT_CONTAINER_START, AUDIT_CONTAINERID,
> AUDIT_CONTAINER_ID, or something else. The API call that sets the ID
> for filtering could be AUDIT_CID or AUDIT_CONTID if that helps decide
> what the initial event might be. Normally, it should match the field
> being filtered.

Ok, I had shortened the record field name to "contid=" to be unique
enough while not using too much netlink bandwidth.  I could have used
"cid=" but that could be unobvious or ambiguous.  I didn't want to use
the full "containerid=" due to that.  I suppose I could change the
field name macro to AUDIT_CONTID.

For the one that starts the container, I'd prefer to leave the name a
bit more general than "_INIT", "_START", so maybe I'll swap them around
and use AUDIT_CONTAINER_INFO for the startup record, and use
AUDIT_CONTAINER for the syscall auxiliary record.

Does that work?

> -Steve

- RGB

--
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
