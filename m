Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D57BB3C1094;
	Fri, 25 Sep 2026 13:45:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790343958; cv=none; b=PsbNU2B7dM2tRWuHX95M6GpT7VZslIBCo/LspZs4R1L3eqnmPj/BJWy0WCw/NLTtXhAlKM8u/CqfsG/t9WOqmBlSG9eXlbaw5HIG5BFkOc3ssodwN5/d3hgJq5bb79h+zof34melBOkMCLhSX+MPSF9zck8zzRBSmOsmAELRgCI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790343958; c=relaxed/simple;
	bh=dRl1yVhiXESaw3QxbXdm8h50uudzdf7P9l3hydLvojw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=oCJLZeN8heuq9rnVjEHTms8KZlqEowBGnxhZ9MgRLP3PYBT5a7k6k+xvHQMzqWHnM90tsFv33g4rAn2QaEw4dBlHSlRMEXbz0nnZuJrDG4Z+pFTE8oaOC6eP3vNNL4pEupTGFoo3A0DzFr/dzGJDhcxfznuXF+FRFMjoCw+pzAo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=E7p2wa2x; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="E7p2wa2x"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 736931F000FF;
	Fri, 25 Sep 2026 13:45:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790343957;
	bh=59nxGZHJvZr5XQ75rR1WP8mIQYoF7VHfx/7++gmKwVs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=E7p2wa2x0o2/f0OxRCp/ys2zOdoPobNAspj4UQaYXeiqO9y1Ft4AXI5pjAYa6FLnD
	 QLI2fz/jl875IcpiMY2QdsIJcG91Xx628FjOP6OeleSwqTzm3AzZmojY6OurOGv1fh
	 1KUVCxFddAEmQThy+IljjjMVWBMsuImkSocJasvDTh5/BnM5LytuAzKs2yV0OQTmI7
	 YpdJ4xv7Tu/q8mFMpP8aYnX6U9w759/UtRtQ9/LYwJ6Zh64os3XgUyoXFVaGfMSnc/
	 zz4880ZdoLWegb9GrKdj0rU0IAzme7+CtIgVB3X6W/gInnRm9ib5CCHdB+GmQjxcxx
	 kmQ7zmcnWHfrw==
Date: Fri, 25 Sep 2026 15:45:51 +0200
From: Christian Brauner <brauner@kernel.org>
To: Kir Kolyshkin <kolyshkin@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, 
	Aleksa Sarai <cyphar@cyphar.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@kernel.org>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, David Howells <dhowells@redhat.com>, 
	Amir Goldstein <amir73il@gmail.com>, Andrei Vagin <avagin@google.com>, Shuah Khan <shuah@kernel.org>, 
	Giuseppe Scrivano <giuseppe@scrivano.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, containers@lists.linux.dev
Subject: Re: [RFC PATCH] mount: add OPEN_TREE_SKIP_MNTNS
Message-ID: <20260925-zugnummer-intolerant-unwahr-2cddd52e435c@brauner>
References: <20260923205028.711077-1-kolyshkin@gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20260923205028.711077-1-kolyshkin@gmail.com>

On Wed, Sep 23, 2026 at 01:50:25PM -0700, Kir Kolyshkin wrote:
> crun, a container runtime, recently started using OPEN_TREE_NAMESPACE to
> set up the container's mount namespace, and open_tree(OPEN_TREE_CLONE)
> for the sources of its bind mounts.  This turns out not to work on hosts
> that have a mount namespace pinned anywhere below such a source: the
> recursive clone picks the pinned namespace up, and move_mount(2) then
> refuses to attach the tree with ELOOP from check_for_nsfs_mounts().
> This was reported to crun in [1].

Yeah, I think that makes sense. Please split this into two patches
though: semantic changes separate from test changes. Maybe call it
OPEN_TREE_DROP_MNTNS_MOUNTS instead?
