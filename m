From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46174-g44430da
Date: Tue, 04 Aug 2009 14:00:28 -0400
Message-ID: <4A78773C.8010502@librato.com>
References: <200908040819.n748JdW9019915@gorgona.ncl.cs.columbia.edu>
	<87skg7lg3z.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87skg7lg3z.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Dan Smith wrote:
> OL>  ipc/checkpoint_shm.c           |   23 +++++++-
> 
> This didn't compile for me until I made the following (untested)
> change:
> 
> diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
> index 48bf026..ac19ff0 100644
> --- a/ipc/checkpoint_shm.c
> +++ b/ipc/checkpoint_shm.c
> @@ -112,7 +112,8 @@ int checkpoint_ipc_shm(int id, void *p, void *data)
>         if (ret < 0)
>                 goto out;
>  
> -       ret = checkpoint_memory_contents(ctx, NULL, file->f_dentry->d_inode);
> +       ret = checkpoint_memory_contents(ctx, NULL,
> +                                        shp->shm_file->f_dentry->d_inode);

Doh !  thanks ...  (actually, 'inode' would do it :)
Pushed to ckpt-v17-dev.

Oren.
