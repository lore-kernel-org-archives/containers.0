Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5FCD833EC
	for <containers@lists.linux.dev>; Wed, 25 Jan 2023 23:36:30 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A6638C433D2;
	Wed, 25 Jan 2023 23:36:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linux-foundation.org;
	s=korg; t=1674689790;
	bh=W6HQ8MA0yrgY78AuioxRnZ92kiAT5egdp56hd0Zn8bA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Guj4q8Wlu/BQ0vrXh0xj8fH4hmAV+wXBAgut16Iz4qfH5Xphsfr9+wI7wY0LbxLs0
	 CS+kZDuXdKZL0IfNs9/WVlNNqB/+kL/EHGW+nfnbfIKFU7fyfPIQlkRl0kIFhI8OMM
	 ZRYzYl1BLSaJA+JEhljHJwTQEqnERMYgL6Np0Cac=
Date: Wed, 25 Jan 2023 15:36:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, containers@lists.linux.dev,
 linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Al
 Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, Val
 Cowan <vcowan@redhat.com>
Subject: Re: [RFC PATCH v1 0/6] proc: Add allowlist for procfs files
Message-Id: <20230125153628.43c12cbe05423fef7d44f0dd@linux-foundation.org>
In-Reply-To: <cover.1674660533.git.legion@kernel.org>
References: <cover.1674660533.git.legion@kernel.org>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Wed, 25 Jan 2023 16:28:47 +0100 Alexey Gladkov <legion@kernel.org> wrote:

> The patch expands subset= option. If the proc is mounted with the
> subset=allowlist option, the /proc/allowlist file will appear. This file
> contains the filenames and directories that are allowed for this
> mountpoint. By default, /proc/allowlist contains only its own name.
> Changing the allowlist is possible as long as it is present in the
> allowlist itself.
> 
> This allowlist is applied in lookup/readdir so files that will create
> modules after mounting will not be visible.
> 
> Compared to the previous patches [1][2], I switched to a special virtual
> file from listing filenames in the mount options.
> 

Changlog doesn't explain why you think Linux needs this feature.  The
[2/6] changelog hints that containers might be involved.  IOW, please
fully describe the requirement and use-case(s).

Also, please describe why /proc/allowlist is made available via a mount
option, rather than being permanently present.

And why add to subset=, instead of a separate mount option.

Does /proc/allowlist work in subdirectories?  Like, permit presence of
/proc/sys/vm/compact_memory?

I think the whole thing is misnamed, really.  "allowlist" implies
access permissions.  Some of the test here uses "visibility" and other
places use "presence", which are better.  "presentlist" and
/proc/presentlist might be better.  But why not simply /proc/contents?

Please run these patches through checkpatch and consider the result.
