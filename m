From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] File name length limit off by sizeof(struct ckpt_hdr)
Date: Tue, 27 Oct 2009 01:04:13 -0500
Message-ID: <20091027060413.GA27733@us.ibm.com>
References: <bb799d3c1e3e27d60dac114992c3e310fe14a9e6.1256320668.git.matthltc@us.ibm.com>
	<633d58fa4318bd9ae8d9955cfa70d246184c38a5.1256320668.git.matthltc@us.ibm.com>
	<4AE24A59.8020801@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AE24A59.8020801-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> 
> Matt Helsley wrote:
> > Unlike the length passed into ckpt_write_obj_type, the maximum length passed
> > to ckpt_read_buf_type must include the length of the struct ckpt_hdr.
> 
> IMHO, the right way to fix this is to change ckpt_read_obj_type().
> 
> This will preserve symmetry between checkpoint and restart, and also
> fix a similar problem in kernel/groups.c (MAX_GROUPINFO_SIZE).
> 
> No need to resend - I'll fix already.

Oren: note with your version of the patch, restore_open_fname()
does 'return len' giving me

checkpoint/files.c: In function 'restore_open_fname':
checkpoint/files.c:457: warning: return makes pointer from integer without a cast

-serge
